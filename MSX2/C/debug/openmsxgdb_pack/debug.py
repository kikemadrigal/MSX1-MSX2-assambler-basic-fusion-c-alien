
import re
import logging

from openmsxgdb_pack.breakpoints import BreakPoints
from z80dis import z80

class Debug(BreakPoints):
    def __init__(self):
        BreakPoints.__init__(self)
        self.logger = logging.getLogger('openmsxgdb.debug')

    def regs_read(self):
        regs = {}
        regtext = self.openmsx.command('cpuregs')
        if regtext != None and 'data' in regtext:
            data = regtext['data']
            if data != None:
                reglist = re.findall("(([\w']{1,3})\s{0,2}=([0-9A-F]{2,4}))+", regtext['data'])
                for entry in reglist:
                    regs[entry[1]] = int(entry[2], 16)
        return regs

    def __breaked(self):
        response = self.openmsx.command("debug breaked")
        return int(response['data']) == 1

    def __break(self):
        self.openmsx.command("debug break")

    def __continue(self):
        self.openmsx.command("debug cont")

    def __break_restore(self, breaked):
        if breaked:
            self.__break()
        else:
            self.__continue()

    def disassemble_line(self, buffer, addr, offset, showbase=True):
        # No slot/bank setting yet
        self.logger.info("disassemble_line(addr={}, showBase={})".format(addr, showbase))
        # response = self.openmsx.command("debug disasm {0:#x}".format(addr))
        decoded = z80.decode(buffer[offset:offset+5], 0)
        # self.logger.info("  response={}".format(response))
        # Match for the bytes is not perfect, but might just be good enough
        # rec = re.match("\{(.*)\}\s([0-9a-fA-F\s]+)", response['data'])
        # bytesInLine = 1
        # if rec != None:
        #     disasm = rec.group(1).strip()
        #     bytesInLine = int(len(rec.group(2).strip().replace(' ','')) / 2)
        # else:
        #     disasm = response['data'].strip()
            
        base = self.cdb.findBaseSymbolOfAddress(addr)
        if base != None:
            if showbase:
                self.gdb_respond("    {0:#x} <{1}+{2}>:\t{3}".format(addr, base['name'], addr - base['address'], z80.disasm(decoded)))
            else:
                self.gdb_respond("    {0:#x} <+{2}>:\t{3}".format(addr, base['name'], addr - base['address'], z80.disasm(decoded)))
        else:
            self.gdb_respond("    {0:#x}:\t{1}".format(addr, z80.disasm(decoded)))
            
        return decoded.len

    def disassemble(self, addr, bytecount=16, showbase=True): 
        self.logger.info("disassemble(addr={}, bytecount={}, showbase={})".format(addr, bytecount, showbase))
        # breaked = self.__breaked()
        # self.__break()
        response = self.openmsx.command("debug_bin2hex [ debug read_block {{slotted memory}} 0x4{:04x} {} ]".format(addr, bytecount + 3))
        buffer = bytes(bytearray.fromhex(response['data']))
        offset = 0
        while bytecount > 0:
            bytesInLine = self.disassemble_line(buffer, addr, offset, showbase)
            offset += bytesInLine
            addr += bytesInLine
            bytecount -= bytesInLine
        # self.__break_restore(breaked)
