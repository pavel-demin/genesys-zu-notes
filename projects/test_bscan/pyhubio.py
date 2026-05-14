import usb1
import numpy as np
import time


class PyhubJTAG:
    def __init__(self, vid=0x0403, pid=0x6011):
        self.id = (vid, pid)
        self.context = None
        self.device = None
        self.timeout = 1000

    def start(self):
        if self.device:
            return
        self.context = usb1.USBContext()
        self.device = self.context.openByVendorIDAndProductID(*self.id)
        if self.device is None:
            raise Exception("unable to access USB device")
        self.device.claimInterface(0)
        # reset mode
        self.device.controlWrite(0x40, 0x0B, 0x0000, 0x01, bytes(), self.timeout)
        # mpsse mode
        self.device.controlWrite(0x40, 0x0B, 0x0200, 0x01, bytes(), self.timeout)
        # latency timer
        self.device.controlWrite(0x40, 0x09, 0x0001, 0x01, bytes(), self.timeout)

    def stop(self):
        if self.device is None:
            return
        self.context.close()
        self.context = None
        self.device = None

    def flush(self):
        if self.device is None:
            return
        # read possible residual command
        while len(self.device.bulkRead(0x81, 512, self.timeout)) > 2:
            continue
        # purge buffers
        self.device.controlWrite(0x40, 0x00, 0x0001, 0x01, bytes(), self.timeout)
        self.device.controlWrite(0x40, 0x00, 0x0002, 0x01, bytes(), self.timeout)

    def setup(self):
        if self.device is None:
            return
        buffer = np.zeros(2, np.uint8)
        # loopback
        command = [0x85, 0xAB]
        self.write_data(np.uint8(command))
        self.read_data(buffer)
        # clock
        command = [0x8A, 0x86, 0x00, 0x00, 0xAB]
        self.write_data(np.uint8(command))
        self.read_data(buffer)
        # gpio
        command = [0x80, 0xE8, 0xEB, 0xAB]
        self.write_data(np.uint8(command))
        self.read_data(buffer)

    def write_data(self, data):
        if self.device is None:
            return
        self.device.bulkWrite(0x02, data.tobytes(), self.timeout)

    def read_data(self, data):
        if self.device is None:
            return
        view = data.view(np.uint8)
        offset = 0
        limit = view.size
        while offset < limit:
            buffer = self.device.bulkRead(0x81, 16384, self.timeout)
            buffer = np.frombuffer(buffer, np.uint8)
            buffer = buffer[np.mod(np.arange(buffer.size), 512) > 1]
            size = buffer.size
            view[offset : offset + size] = buffer
            offset += size

    def tms(self, data, bits):
        command = [0x4B, bits - 1, data]
        self.write_data(np.uint8(command))

    def idle(self):
        self.tms(0x1F, 6)

    def shift_dr(self):
        self.tms(0x01, 3)

    def shift_ir(self):
        self.tms(0x03, 4)

    def read_bits(self, bits):
        command = [0x2E, bits - 2] if bits > 1 else []
        command += [0x6F, 2, 0x03]
        self.write_data(np.uint8(command))
        buffer = np.zeros(1 + (bits > 1), np.uint8)
        self.read_data(buffer)
        if bits > 1:
            return ((buffer[1] >> 5) & 1) << (bits - 1) | buffer[0] >> (9 - bits)
        else:
            return (buffer[0] >> 5) & 1

    def write_bits(self, data, bits):
        command = [0x1B, bits - 2, data] if bits > 1 else []
        command += [0x4B, 2, ((data >> (bits - 1)) & 1) << 7 | 0x03]
        self.write_data(np.uint8(command))

    def read_bytes(self, data, bits=8):
        view = data.view(np.uint8)
        for part in np.split(view[:-1], np.arange(65536, view.size - 1, 65536)):
            size = part.size - 1
            command = [0x2C, size & 0xFF, size >> 8]
            self.write_data(np.uint8(command))
            self.read_data(part)
        view[-1] = self.read_bits(bits)

    def write_bytes(self, data, bits=8):
        view = data.view(np.uint8)
        for part in np.split(view[:-1], np.arange(65536, view.size - 1, 65536)):
            size = part.size - 1
            command = [0x19, size & 0xFF, size >> 8]
            self.write_data(np.uint8(command))
            self.write_data(part)
        self.write_bits(view[-1], bits)

    def idcode(self):
        buffer = np.zeros(3, np.uint32)
        if self.device is None:
            return buffer
        self.shift_ir()
        self.write_bytes(np.uint16([0x265E]))
        self.shift_dr()
        self.read_bytes(buffer)
        return buffer

    def enable(self):
        if self.device is None:
            return
        self.shift_ir()
        self.write_bytes(np.uint16([0x83FF]))
        self.shift_dr()
        self.write_bytes(np.uint32([0x00000003]))
        self.idle()

    def configure(self, path):
        if self.device is None:
            return
        data = np.fromfile(path, np.uint8)
        for i in range(data.size - 4):
            if np.array_equal(data[i : i + 4], [0xAA, 0x99, 0x55, 0x66]):
                break
        data = data[i:]
        data = (data >> 1) & 0x55 | (data & 0x55) << 1
        data = (data >> 2) & 0x33 | (data & 0x33) << 2
        data = (data >> 4) & 0x0F | (data & 0x0F) << 4
        # jprogram
        self.shift_ir()
        self.write_bytes(np.uint16([0x90BF]))
        self.idle()
        time.sleep(0.01)
        # cfg_in
        self.shift_ir()
        self.write_bytes(np.uint16([0x905F]))
        self.shift_dr()
        self.write_bytes(data)

    def program(self, path):
        self.start()
        self.flush()
        self.setup()
        self.idle()
        self.enable()
        self.configure(path)
        self.stop()

    def read(self, data, port=1, addr=0):
        view = data.view(np.uint32)
        self.shift_ir()
        self.write_bytes(np.uint16([0x902F]))
        self.shift_dr()
        for part in np.split(view, np.arange(1024, view.size, 1024)):
            size = part.size
            command = np.uint32([(size - 1) << 21 | (port & 0x7) << 18 | addr & 0x3FFFF])
            addr += size
            self.write_data(np.concatenate([np.uint8([0x19, 3, 0]), command.view(np.uint8), np.uint8([0x1B, 7, 0, 0x2C, (size * 4 - 1) & 0xFF, (size * 4 - 1) >> 8])]))
            self.read_data(part)
        self.idle()

    def write(self, data, port=0, addr=0):
        view = data.view(np.uint32)
        self.shift_ir()
        self.write_bytes(np.uint16([0x902F]))
        self.shift_dr()
        for part in np.split(view, np.arange(1024, view.size, 1024)):
            size = part.size
            command = np.uint32([1 << 31 | (size - 1) << 21 | (port & 0x7) << 18 | addr & 0x3FFFF])
            addr += size
            self.write_data(np.concatenate([np.uint8([0x19, 3, 0]), command.view(np.uint8), np.uint8([0x19, (size * 4 - 1) & 0xFF, (size * 4 - 1) >> 8])]))
            self.write_data(part)
        self.idle()
