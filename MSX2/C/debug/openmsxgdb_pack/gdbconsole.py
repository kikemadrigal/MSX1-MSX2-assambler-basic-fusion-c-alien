#!/usr/bin/python3
#
# OpenMSX GDB
#
# Copyright (c) 2015-2016  Erik Maas
#    
# SPDX-License-Identifier: MIT

# TODO: Find out if it is allowed to copy textual output of GPL licensed tools. The GDB responses are copied into this file
#       to be able to fool DDD that it is talking to GDB. 

import argparse
import textwrap
import time
import os
import sys
import string
import re
import logging
from os.path import basename,dirname
from os import path
from pathlib import Path

# import xml.etree.ElementTree as ET
from openmsxgdb_pack.cdbreader import CdbReader
from openmsxgdb_pack.openmsxrpc import OpenmsxRpc
from openmsxgdb_pack.debug import Debug   

description = textwrap.dedent("""
The OpenMSX GDB debugger is an attempt to connect GDB compatible debuggers to the openMSX
emulator. Executables launched into openMSX are typically not real executables. This can be
rather diverse.

 * a .com file, loaded from MSX-DOS
 * a .bin file, loaded from BASIC
 * a ROM file inserted in a some slot
 * a .dsk file
 
This means that an executable requires some extra information on how to debug it.
(TDB)""" )

class GdbConsole(Debug):
    def __init__(self, program=None, sourcedir=None, debug=False):
        
        self.program = program
        self.sourcedir = sourcedir
        self.actfile = None
        self.actline = None
        self.waitsuspended = False
        self.tempbreaks = []
        self.responses = []
        Debug.__init__(self)
        
        self.logger = logging.getLogger('openmsxgdb')
        if debug:
            # self.logger.setLevel(logging.DEBUG)
            fh = logging.StreamHandler(sys.stderr)
        else:
            fh = logging.FileHandler('openmsxgdb.log')
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        fh.setFormatter(formatter)
        self.logger.addHandler(fh)
        
        self.openmsx = OpenmsxRpc(callback=self.__openMSXcallback)
        self.openmsx.open()
        while not self.openmsx.isConnected():
            time.sleep(0.1)
        self.gdb_respond("connected")

        self.openmsx.command('openmsx_update enable status')

        self.openmsx.command('debug break')
        self.openmsx.command('reset')

        self.openmsx.command('carta eject')
        self.openmsx.command('carta {0}.rom'.format(program))

        if self.program != None:
            cdbfiles = []
            cdbfiles.append("{0}.cdb".format(self.program))
            self.cdb=CdbReader(cdbfiles=cdbfiles, sourcedirs=self.sourcedir)
            self.gdb_respond("Reading symbols from ./{0}...done.".format(self.program))

        self.break_sync()
        bplist = self.break_list()
        if bplist != None:
            for entry in bplist:
                self.break_delete(entry['num'])
#         mainaddr = self.cdb.findLinkAddressOfSymbol('main')
#         if mainaddr != None:
#             self.break_set(mainaddr['address'])
#             self.openmsx.command('debug cont')

    def __showCurrentLocation(self, address, cline):
        return self.gdb_respond("\032\032{0}:{1}:970:beg:{2:#x}".format(cline['filename'], cline['line'], address))

    def __showBreakpoint(self, address):
        bplist = self.break_list()
        if bplist != None:
            found = False
            for bpentry in bplist:
                if address == bpentry['address']:
                    found = True
                    symbol = self.cdb.findBaseSymbolOfAddress(bpentry['address'])
                    cline = self.cdb.addressToCline(bpentry['address'])
                    if symbol != None and cline != None:
                        self.gdb_respond("Breakpoint {0}, {1} (argc=1, argv=0x2354) at {2}:{3}".format(bpentry['num'], symbol['name'], os.path.basename(cline['filename']), cline['line']))
                        self.__showCurrentLocation(address, cline)
                    else:
                        self.gdb_respond("Breakpoint {0}, <unknown>".format(bpentry['num']))
            if found == False:
                symbol = self.cdb.findBaseSymbolOfAddress(address)
                cline = self.cdb.addressToCline(address)
                if symbol != None and cline != None:
                    self.gdb_respond("Breakpoint {0}, {1} (argc=1, argv=0x2354) at {2}:{3}".format(0, symbol['name'], os.path.basename(cline['filename']), cline['line']))
        else:
            self.gdb_respond("Breakpoint {0}, <unknown>".format('none'))
            
        self.gdb_respond("(gdb) ", crlf=False)

    def __openMSXcallback(self, msg):
        if msg.tag == 'update':
            if (msg.attrib['name'] == 'cpu') and (msg.attrib['type'] == 'status'):
                if msg.text == 'suspended':
                    if self.waitsuspended:
                        for bp in self.tempbreaks:
                            self.openmsx.command("debug remove_bp bp#{0}".format(bp))
                            response = self.openmsx.command("debug set_bp {0:#x}".format(bp['address']))
                            self.tempbreaks.append(bp)
                        self.waitsuspended = False
                        regs = self.regs_read()
                        self.gdb_respond("update:suspended")
                        self.__showBreakpoint(regs['PC'])
            
    def gdb_respond(self, value, crlf=True):
        self.logger.info("response: {}".format(value.strip()))
        self.responses.append("{0}".format(value.strip()))
        if crlf:
            sys.stdout.write("{0}\n".format(value))
        else:
            sys.stdout.write("{0}".format(value))
        sys.stdout.flush()
            
    def __find_sourcefile(self, filename):
        self.logger.info("Searching for {}".format(filename))
        if path.exists(filename) and path.isfile(filename):
            self.logger.info("Found {}".format(filename))
            return filename
        for location in (["."] + self.sourcedir):
            pathname = Path(location)
            fullname = pathname / filename
            if path.exists(fullname) and path.isfile(fullname):
                self.logger.info("Found {} in {}".format(filename, fullname))
                return fullname
        self.logger.info("Could not find {}".format(filename))
        return None

    def cmd_list(self, line):
        if (self.actfile == None) or (self.actline == None):
            cline = self.cdb.symbolToCline('main')
            if cline != None:
                self.logger.info("Symbol 'main' maps to {0}:{1}".format(cline['filename'], cline['line']))
                self.actfile = cline['filename']
                self.actline = cline['line']
            else:
                self.gdb_respond("Unable to resolve symbol 'main' to cline")
                return
        
        if line == "":
            line_min = self.actline - 4
            line_max = self.actline + 7
        else:
            args = line.split(" ", 1)
            self.actline = 0
            self.actfile = args[0].split(":")[0]  #"main.c"
            line_min = self.actline - 6
            line_max = self.actline + 7
                        
        line = 0
        # Need to search for the correct sourcefile
        sourcefile = self.__find_sourcefile(self.actfile)
        if sourcefile is not None:
            with open("{0}".format(sourcefile)) as f:
                for fline in f:
                    line += 1
                    if (line > line_min) and (line < line_max):
                        self.actline = line
                        self.gdb_respond("{0}\t{1}".format(line, fline.strip("\n")))
                    if line >= line_max:
                        return
        
    def cmd_output(self, line):
        ''' Print the value of expression
            Assumption now is that this will be used to read variables from memory
        ''' 
        args = line.split(" ", 1)
        self.gdb_respond("{0}".format(args[0]), crlf=False)
        
    def cmd_show(self, line):
        args = line.split(" ", 1)
        if args[0] == "history":
            if args[1] == "filename":
                self.gdb_respond("The filename in which to record the command history is \"/home/maase/src/test/.gdb_history\".")
            elif args[1] == "size":
                self.gdb_respond("The size of the command history is 256.")
            else:
                self.gdb_respond("Unsupported history argument \"{0}\".".format(args[1]))
        elif args[0] == "language":
            self.gdb_respond("The current source language is \"auto; currently c\".")
        elif args[0] == "version":
            #self.gdb_respond("GNU gdb (Ubuntu 7.7.1-0ubuntu5~14.04.2) 7.7.1")
            self.gdb_respond("Eriks GDB 0.0")
            self.gdb_respond("Copyright (C) 2016 Erik Maas")

        else:
            self.gdb_respond("Unsupported show argument \"{0}\".".format(args[0]))

    def get_linecount(self, filename):
        lc = 0
        try:
            with open(filename, mode='r') as f:
                for line in f:
                    lc += 1
        except Exception:
            pass
        return lc

    def cmd_help(self, line):
        args = line.split(" ", 1)
        if args[0] == "detach":
            self.gdb_respond("Detach a process or file previously attached.")
            self.gdb_respond("If a process, it is no longer traced, and it continues its execution.  If")
            self.gdb_respond("you were debugging a file, the file is closed and gdb no longer accesses it.")
            self.gdb_respond("")
            self.gdb_respond("List of detach subcommands:")
            self.gdb_respond("")
            self.gdb_respond("detach checkpoint -- Detach from a checkpoint (experimental)")
            self.gdb_respond("detach inferiors -- Detach from inferior ID (or list of IDS)")
            self.gdb_respond("")
            self.gdb_respond("Type \"help detach\" followed by detach subcommand name for full documentation.")
            self.gdb_respond("Type \"apropos word\" to search for commands related to \"word\".")
            self.gdb_respond("Command name abbreviations are allowed if unambiguous.")
        elif args[0] == "run":
            self.gdb_respond("Start debugged program.  You may specify arguments to give it.")
            self.gdb_respond("Args may include \"*\", or \"[...]\"; they are expanded using \"sh\".")
            self.gdb_respond("Input and output redirection with \">\", \"<\", or \">>\" are also allowed.")
            self.gdb_respond("")
            self.gdb_respond("With no arguments, uses arguments last specified (with \"run\" or \"set args\").")
            self.gdb_respond("To cancel previous arguments and run with no arguments,")
            self.gdb_respond("use \"set args\" without arguments.")
        elif args[0] == "step":
            self.gdb_respond("Step program until it reaches a different source line.")
            self.gdb_respond("Usage: step [N]")
            self.gdb_respond("Argument N means step N times (or till program stops for another reason).")
        elif args[0] == "stepi":
            self.gdb_respond("Step one instruction exactly.")
            self.gdb_respond("Usage: stepi [N]")
            self.gdb_respond("Argument N means step N times (or till program stops for another reason).")
        elif args[0] == "next":
            self.gdb_respond("Step program, proceeding through subroutine calls.")
            self.gdb_respond("Usage: next [N]")
            self.gdb_respond("Unlike \"step\", if the current source line calls a subroutine,")
            self.gdb_respond("this command does not enter the subroutine, but instead steps over")
            self.gdb_respond("the call, in effect treating it as a single source line.")
        elif args[0] == "nexti":
            self.gdb_respond("Step one instruction, but proceed through subroutine calls.")
            self.gdb_respond("Usage: nexti [N]")
            self.gdb_respond("Argument N means step N times (or till program stops for another reason).")
        elif args[0] == "until":
            self.gdb_respond("Execute until the program reaches a source line greater than the current")
            self.gdb_respond("or a specified location (same args as break command) within the current frame.")
        elif args[0] == "finish":
            self.gdb_respond("Execute until selected stack frame returns.")
            self.gdb_respond("Usage: finish")
            self.gdb_respond("Upon return, the value returned is printed and put in the value history.")
        elif args[0] == "cont":
            self.gdb_respond("Continue program being debugged, after signal or breakpoint.")
            self.gdb_respond("Usage: continue [N]")
            self.gdb_respond("If proceeding from breakpoint, a number N may be used as an argument,")
            self.gdb_respond("which means to set the ignore count of that breakpoint to N - 1 (so that")
            self.gdb_respond("the breakpoint won\'t break until the Nth time it is reached).")
            self.gdb_respond("")
            self.gdb_respond("If non-stop mode is enabled, continue only the current thread,")
            self.gdb_respond("otherwise all the threads in the program are continued.  To ")
            self.gdb_respond("continue all stopped threads in non-stop mode, use the -a option.")
            self.gdb_respond("Specifying -a and an ignore count simultaneously is an error.")
        elif args[0] == "signal":
            self.gdb_respond("Continue program with the specified signal.")
            self.gdb_respond("Usage: signal SIGNAL")
            self.gdb_respond("The SIGNAL argument is processed the same as the handle command.")
            self.gdb_respond("")
            self.gdb_respond("An argument of \"0\" means continue the program without sending it a signal.")
            self.gdb_respond("This is useful in cases where the program stopped because of a signal,")
            self.gdb_respond("and you want to resume the program while discarding the signal.")
        elif args[0] == "kill":
            self.gdb_respond("Kill execution of program being debugged.")
            self.gdb_respond("")
            self.gdb_respond("List of kill subcommands:")
            self.gdb_respond("")
            self.gdb_respond("kill inferiors -- Kill inferior ID (or list of IDs)")
            self.gdb_respond("")
            self.gdb_respond("Type \"help kill\" followed by kill subcommand name for full documentation.")
            self.gdb_respond("Type \"apropos word\" to search for commands related to \"word\".")
            self.gdb_respond("Command name abbreviations are allowed if unambiguous.")
        elif args[0] == "up":
            self.gdb_respond("Select and print stack frame that called this one.")
            self.gdb_respond("An argument says how many frames up to go.")
        elif args[0] == "down":
            self.gdb_respond("Select and print stack frame called by this one.")
            self.gdb_respond("An argument says how many frames down to go.")
        else:
            self.gdb_respond("Unknown command {0}".format(args[0]))
        
    def cmd_info(self, line):
        args = line.split(" ", 1)
        if args[0] == "source":
            if self.actfile != None:
                self.gdb_respond("Current source file is {0}".format(basename(self.actfile)))
                self.gdb_respond("Compilation directory is {0}".format(dirname(self.actfile)))
                self.gdb_respond("Located in {0}".format(self.actfile))
                self.gdb_respond("Contains {0} lines.".format(self.get_linecount(self.actfile)))
                self.gdb_respond("Source language is c.")
                self.gdb_respond("Compiled with undefined debugging format.")
                self.gdb_respond("Does not include preprocessor macro info.")
            else:
                self.gdb_respond("No source file selected.")
        elif args[0] == "display":
            self.gdb_respond("There are no auto-display expressions now.")
        elif args[0] == "files":
            self.gdb_respond("Symbols from \\\"{0}\\\".".format(self.program))
            self.gdb_respond("Local exec file:")
            self.gdb_respond("\t`{0}', file type elf64-x86-64.".format(self.program))
            self.gdb_respond("\tEntry point: 0x4010")
            
            
        elif args[0] == "breakpoints":
            # No slot/bank setting yet
            bplist = self.break_list()
            if len(bplist) > 0:
                self.gdb_respond("{0:8}{1:15}{2:5}{3:4}{4:19}{5}".format("Num", "Type", "Disp", "Enb", "Address", "What"))
                for entry in bplist:
                    what = "Undefined"
                    symbol = self.cdb.findBaseSymbolOfAddress(entry['address'])
                    cline = self.cdb.addressToCline(entry['address'])
                    if symbol != None and cline != None:
                        what = "in {0} at {1}:{2}".format(symbol['name'], os.path.basename(cline['filename']), cline['line'])
                    self.gdb_respond("{0:7} {1:14} {2:4} {3:3} {4:#018x} {5}".format(entry['num'], "breakpoint", "keep", "y", entry['address'], what))
            else:
                self.gdb_respond("No breakpoints or watchpoints.")

        elif args[0] == "registers":
            regs = self.regs_read()
            
            if regs != None:
                for reg in ["AF", "HL", "DE", "BC"]:
                    self.gdb_respond("{0:12} {1:#06x}".format(reg, regs[reg]))
                for reg in ["AF'", "HL'", "DE'", "BC'"]:
                    self.gdb_respond("{0:12} {1:#06x}".format(reg, regs[reg]))
                for reg in ["IX", "IY", "PC", "SP"]:
                    self.gdb_respond("{0:12} {1:#06x}".format(reg, regs[reg]))
                for reg in ["I", "R", "IM"]:
                    self.gdb_respond("{0:12} {1:#04x}".format(reg, regs[reg]))
            
        elif args[0] == "line":
            if len(args) > 1:
                self.cmd_info_line(args[1])
            else:
                self.cmd_info_line(None)
        elif args[0] == "program":
            self.gdb_respond("The program being debugged is not being run.")
            
    def cmd_info_line(self, line):
        if (line == None) or (line == ""):
            if (self.actfile == None) or (self.actline == None):
                self.gdb_respond("No line number information available.")
            else:
                info = self.cdb.ClineToAddress(self.actfile, self.actline)
                if info == None:
                    self.gdb_respond("No line number information available for {0}:{1}.".format(self.actfile, self.actline))
                else:
                    base = self.cdb.findBaseSymbolOfAddress(info['address_begin'])
                    if base == None:
                        base['name'] = 'unknown'
                        base['address'] = info['address_begin']
                    self.gdb_respond("Line {0} of \"{1}\" starts at address {2:#x} <{4}+{5}> and ends at {3:#x} <{4}+{6}>.".format(
                        self.actline, basename(self.actfile), 
                        info['address_begin'], info['address_end'],
                        base['name'], info['address_begin'] - base['address'], info['address_end'] - base['address']
                        ))
        elif line.startswith("*"):
            line = line.strip("*")
            address = line.atoi()
            location = self.cdb.addressToCline(address)
            self.gdb_respond("Line {0} of \"{1}\" starts at pc {2:#x} and ends at {3:#x}".format(location['line'], location['file'], 0, 0))
        else:
            self.gdb_respond("line number {0} is out of range for \"{1}\".".format(self.actline, self.actfile))


    def cmd_disassemble(self, line):
        rec = re.match("(0x[0-9a-fA-F]+)(.*)", line)
        if rec != None:
            bytecount = 16
            addr = int(rec.group(1), 16)
            base = self.cdb.findBaseSymbolOfAddress(addr)
            # If there is a matching symbol with address and endaddress, show the whole function
            if base != None:
                symAddr = self.cdb.findLinkAddressOfSymbol(base['name'], includeEndAddress=True)
                if (symAddr != None) and ('endaddress' in symAddr):
                    addr = symAddr['address']
                    bytecount = symAddr['endaddress'] - symAddr['address']
                    self.gdb_respond("Dump of assembler code for function {0}:".format(base['name']))
                    self.disassemble(addr, bytecount, showbase=False)
                    self.gdb_respond("End of assembler dump.")
                    return
            self.disassemble(addr, bytecount)
        else:
            self.gdb_respond("unable to parse line '{0}'".format(line))
        
    def cmd_x(self, line):
        rec = re.match(r"/([\dxduotacfsibhwg]+)\s+0x([0-9a-fA-F]+)", line)
        if rec != None:
            options = rec.group(1)
            addr = int(rec.group(2), 16)
            self.disassemble(addr, 1)
        else:
            self.gdb_respond("unable to parse line '{0}'".format(line))
        
    def cmd_break(self, line):
        rec = re.match(r"([\w\.]+):(\d+)", line)
        if rec != None:
            filename = rec.group(1)
            linenumber = int(rec.group(2))
            addr = self.cdb.ClineToAddress(filename, linenumber)
            if addr != None:
                self.break_set(addr['address_begin'], addr['address_end'])
            else:
                self.gdb_respond("unable to find matching address for {0}:{1}".format(filename, linenumber))
        else:
            rec = re.match(r"([\w]+)", line)
            if rec != None:
                addr = self.cdb.findLinkAddressOfSymbol(rec.group(1))
                if addr != None:
                    self.break_set(addr['address'])
                else:
                    self.gdb_respond("unable to find matching address for label {0}".format(rec.group(1)))
            else:
                self.gdb_respond("unable to parse line '{0}'".format(line))
        
    def cmd_delete(self, line):
        rec = re.match(r"(\d+)", line)
        if rec != None:
            self.break_delete(rec.group(1))
        else:
            self.gdb_respond("unable to parse line '{0}'".format(line))

    ######################################################################################

    def cmd_step(self, line):
        # Step program until it reaches a different source line.
        # Usage: step [N]
        # Argument N means step N times (or till program stops for another reason).
        # Note: stepping over callbacks might not work properly yet
        # regs = self.regs_read()
        # actline = 
        # breaks = self.cdb.getBreaksInContext(regs['PC'])
        # for bp in breaks:
        #     response = self.openmsx.command("debug set_bp {0:#x}".format(bp['address']))
        #     bp['entry'] = response['']
        #     self.tempbreaks.append(bp)
        # if self.waitsuspended != True:
        #     self.openmsx.command("debug cont")
        regs = self.regs_read()
        prevline = self.cdb.addressToCline(regs['PC'])
        hitline = False
        while hitline == False:
            self.openmsx.command("step_over")
            regs = self.regs_read()
            cline = self.cdb.addressToCline(regs['PC'])
            if cline != None and cline != prevline:
                self.__showCurrentLocation(regs['PC'], cline )
                hitline = True
            
#         hitline = False
#         while hitline == False:
#             self.openmsx.command("step_over")
#             regs = self.regs_read()
#             cline = self.cdb.addressToCline(regs['PC'], exactmatch=True)
#             if cline != None:
#                 self.__showCurrentLocation(regs['PC'], cline )
#                 hitline = True

        # elif args[0] == "step":
        #     self.gdb_respond("Step program until it reaches a different source line.")
        # elif args[0] == "stepi":
        #     self.gdb_respond("Step one instruction exactly.")
        #     self.gdb_respond("Usage: stepi [N]")
        #     self.gdb_respond("Argument N means step N times (or till program stops for another reason).")
        # elif args[0] == "nexti":
        #     self.gdb_respond("Step one instruction, but proceed through subroutine calls.")
        #     self.gdb_respond("Usage: nexti [N]")
        #     self.gdb_respond("Argument N means step N times (or till program stops for another reason).")

    def cmd_next(self, line):
        # Step program, proceeding through subroutine calls.
        # Usage: next [N]
        # Unlike \"step\", if the current source line calls a subroutine,
        # this command does not enter the subroutine, but instead steps over
        # the call, in effect treating it as a single source line.
        hitline = False
        while hitline == False:
            self.openmsx.command("step_in")
            regs = self.regs_read()
            cline = self.cdb.addressToCline(regs['PC'], exactmatch=True)
            if cline != None:
                self.__showCurrentLocation(regs['PC'], cline )
                hitline = True

    def command(self, line):
        self.logger.info("command: {}".format(line))
        args = line.strip().split(" ", 1)
        command = args[0]
        if len(args) > 1:
            line = args[1]
        else:
            line = ""
        #print("command={0} args={1}".format(command, args))
        if command == "#":
            pass
        elif command == "pwd":
            self.gdb_respond("Working directory {0}.".format(os.path.abspath(os.path.curdir)))
        elif command == "reset":
            self.openmsx.command(b"reset")
        elif command == "display":
            pass
        elif command == "info":
            self.cmd_info(line)
        elif command == "list":
            self.cmd_list(line)
        elif command == "output":
            self.cmd_output(line)
        elif command == "show":
            self.cmd_show(line)
        elif command == "set":
            pass
        elif command == "source":
            pass
        elif command.startswith("q"):
            self.openmsx.stop()
            sys.exit(0)
        elif command == "break":
            self.cmd_break(line)
        elif command == "delete":
            self.cmd_delete(line)
        elif command == "x":
            self.cmd_x(line)
        elif command == "disassemble":
            self.cmd_disassemble(line)
        elif command == "help":
            self.cmd_help(line)
        elif command == "run":
            self.gdb_respond("Starting program: {0} ".format(self.program))
            self.openmsx.command('debug break')
            self.openmsx.command('reset')
            self.waitsuspended = True
            self.openmsx.command('debug cont')
            self.gdb_respond("")
            self.showprompt = False
        elif command == "step":
            self.cmd_step(line)
        elif command == "next":
            self.cmd_next(line)
        elif command == "cont":
            self.openmsx.command('debug cont')
            self.showprompt = False
        else:
            self.gdb_respond("unsupported terminal command '{0}'".format(command))

    def console(self):
        self.showprompt = True
        while True:
            command = self.fetchline(self.showprompt)
            self.showprompt = True
            self.command(command)

    def fetchline(self, showprompt=True):
        line = None
        while True:
            if line == None:
                if showprompt:
                    self.gdb_respond("(gdb) ", crlf=False)
                line = ""

            try:
                ch = sys.stdin.read(1)
                if ch == os.linesep:
                    return line.strip()
                elif ch in string.printable:
                    line += ch
                else:
                    self.gdb_respond("Invalid input (ch:{0})".format(int(ch)))
                    line = None
            except (KeyboardInterrupt, SystemExit):
                self.gdb_respond("Quit")
                self.openmsx.stop()
                sys.exit(0)
            except:
                raise
            
    def getresponse(self, timeout = 1.0):
        ref_time = time.time()
        while True:
            if (len(self.responses) != 0):
                return self.responses.pop(0)
            if time.time() - ref_time > timeout:
                return None

            time.sleep(0.01)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, description='OpenMSX GDB debugger', epilog=description)
    parser.add_argument('program', nargs='?', help='executable to debug')
    parser.add_argument('--sourcedir', action='append', help='Directories to scan for c and assembly sources, required if sources are not in the location of the cdb file or the current working directory')
    parser.add_argument('--version', action='version', version="$(prog)s 0.0")
    parser.add_argument('-fullname', action='store_true')
    parser.add_argument('-q', action='store_true')
    args = parser.parse_args()
    
    g = GdbConsole(program=args.program, sourcedir=args.sourcedir)
    g.console()
        
    