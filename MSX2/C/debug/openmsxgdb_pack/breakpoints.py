import re
from os.path import basename

class BreakPoints:
    def __init__(self):
        self.breakpoints = {}
        

    def __bp_entry_to_list(self, line): 
        rec = re.match("bp#(\d+) 0x([0-9a-fA-F]+) .*", line)
        if rec != None:
            address = int(rec.group(2), 16)
            cline = self.cdb.addressToCline(address)
            if cline != None:
                self.gdb_respond("Breakpoint {0} at {1:#x}: file {2}, line {3}.".format(rec.group(1), address, basename(cline['filename']), cline['line']))
            else:
                self.gdb_respond("Breakpoint {0} at {1:#x}.".format(rec.group(1), address))
            bp = { 'num' : rec.group(1), 'address' : address, 'enabled' : True }
            self.breakpoints[rec.group(1)] = bp
            return True
        else:
            return False

    def break_sync(self):
        response = self.openmsx.command("debug list_bp")
        if response['data']:
            self.breakpoints = {}
            for line in response['data'].split("\n"):
                line = line.strip()
                if line != "":
                    if self.__bp_entry_to_list(line) == False:
                        self.gdb_respond("Unable to parse bp response {0}".format(line))
        
    def break_set(self, address, endaddress=None):
        # No slot/bank setting yet
        # debug set_bp 0x???? {[debug read "]}
        response = self.openmsx.command("debug set_bp {0:#x} {{[pc_in_slot {1}]}}".format(address, 1))
        rec = re.match("bp#(\d+).*", response['data'])
        if rec != None:
            cline = self.cdb.addressToCline(address)
            if cline != None:
                self.gdb_respond("Breakpoint {0} at {1:#x}: file {2}, line {3}.".format(rec.group(1), address, basename(cline['filename']), cline['line']))
            else:
                self.gdb_respond("Breakpoint {0} at {1:#x}.".format(rec.group(1), address))
            bp = { 'num' : rec.group(1), 'address' : address, 'enabled' : True }
            self.breakpoints[rec.group(1)] = bp
#             print("breakpoints={0}".format(self.breakpoints))
        else:
            self.gdb_respond("unable to set breakpoint {0}'".format(response['data']))

    def break_list(self):
        # self.break_sync()
        bplist = []
        for bp in self.breakpoints:
            bplist.append(self.breakpoints[bp])
        return bplist

    def break_delete(self, breakpoint=None):
#         print("break_delete({0})".format(breakpoint))
        self.breakpoints.pop(breakpoint)
        #] = None
#         print("breakpoints={0}".format(self.breakpoints))
        self.openmsx.command("debug remove_bp bp#{0}".format(breakpoint))
        
