#!/usr/bin/python3
#
# OpenMSX GDB
#
# Copyright (c) 2015-2016  Erik Maas
#    
# SPDX-License-Identifier: MIT

import os
import re
import logging
from os.path import basename,dirname

class CdbReader:
    def __init__(self, cdbfiles=None, sourcedirs=None, verbose=False):
        self.cdb = []
        self.sourcedirs = []
        self.logger = logging.getLogger('openmsxgdb.cdbreader')
        self.sourcedirs.append(os.getcwd())
        if sourcedirs != None:
            for location in sourcedirs:
                expanded_location = os.path.expanduser(location)
                if not os.path.isdir(expanded_location):
                    raise RuntimeError("{0} is not a directory".format(expanded_location))
                self.sourcedirs.append(expanded_location)
    
        for cdbfile in cdbfiles:
            self.cdb.append(self.readcdbfile(cdbfile))

    def readcdbfile(self, cdbfile):
        lines = []
        if not os.path.isfile(cdbfile):
            raise RuntimeError("cdbfile {0} is not an existing file".format(cdbfile))
        self.logger.info("Parsing ({0})".format(cdbfile))
        with open(cdbfile) as f:
            for line in f:
                line = line.strip()
                rec = re.match("([MFSTL]):(.*)", line)
                if rec == None:
                    self.logger.error("Unparsable line {0}".format(line))
                lines.append(line)
        return {'cdbfile': cdbfile, 'lines' : lines}
        
    def getmodules(self):
        modules = []
        for cdb in self.cdb:
            for line in cdb['lines']:
                rec = re.match("M:(.*)", line)
                if rec != None:
                    module = rec.group(1)
                    modules.append(module)
                    self.logger.debug("Found module {0}".format(module))
        return modules

    def parseLinkAddressOfSymbolScopeGlobal(self, line):
        entry = None
        #                     name       lvl   block  address
        rec = re.match(r"L:G\$([\w\d]+)\$([\d_]+)\$(\d+):([\da-fA-F]+)", line)
        if rec != None:
            name = rec.group(1)
            level = int(rec.group(2))
            block = int(rec.group(3))
            address = int(rec.group(4), 16)
            self.logger.debug("Link Address of Global : Scope=Global, Name={0}, Level={1}, Block={2}, Address={3:#x}".format(name, level, block, address))
            entry = {'name' : name, 'scope' : 'global', 'level' : level, 'block' : block, 'address' : address }
        return entry

    def parseLinkAddressOfSymbolScopeFile(self, line):
        entry = None
        rec = re.match(r"L:F([\w\d]+)\$([\w\d]+)\$([\d_]+)\$(\d+):([\da-fA-F]+)", line)
        if rec != None:
            filename = rec.group(1)
            name = rec.group(2)
            level = int(rec.group(3))
            block = int(rec.group(4))
            address = int(rec.group(5), 16)
            self.logger.debug("Link Address of Symbol : Scope=File({4}), Name={0}, Level={1}, Block={2}, Address={3:#x}".format(name, level, block, address, filename))
            entry = {'name' : name, 'scope':'file', 'filename' : filename, 'level' : level, 'block' : block, 'address' : address }
        return entry
            
    def parseSymbolEndAddressRecordScopeGlobal(self, line):
        entry = None
        rec = re.match(r"L:XG\$([\w\d]+)\$([\d_]+)\$(\d+):([\da-fA-F]+)", line)
        if rec != None:
            name = rec.group(1)
            level = int(rec.group(2))
            block = int(rec.group(3))
            address = int(rec.group(4), 16)
            self.logger.debug("Link Address of Global : Scope=Global, Name={0}, Level={1}, Block={2}, Address={3:#x}".format(name, level, block, address))
            entry = {'name' : name, 'scope' : 'global', 'level' : level, 'block' : block, 'address' : address }
        return entry

    def parseSymbolEndAddressRecordScopeFile(self, line):
        entry = None
        rec = re.match(r"L:XF([\w\d]+)\$([\w\d]+)\$([\d_]+)\$(\d+):([\da-fA-F]+)", line)
        if rec != None:
            filename = rec.group(1)
            name = rec.group(2)
            level = int(rec.group(3))
            block = int(rec.group(4))
            address = int(rec.group(5), 16)
            self.logger.debug("Link Address of Symbol : Scope=File({4}), Name={0}, Level={1}, Block={2}, Address={3:#x}".format(name, level, block, address, filename))
            entry = {'name' : name, 'scope':'file', 'filename' : filename, 'level' : level, 'block' : block, 'address' : address }
        return entry

    def parseCline(self, line):
        entry = None
        #                     name         line  level  block   end address
        rec = re.match(r"L:C\$([\w\d\.]+)\$(\d+)\$([\d_]+)\$(\d+):([0-9a-fA-F]+)", line)
        if rec != None:
            # filename = os.path.abspath(rec.group(1))
            filename = rec.group(1)
            line = int(rec.group(2))
            level = int(rec.group(3))
            block = int(rec.group(4))
            address = int(rec.group(5), 16)
            self.logger.debug("Linker C-Line record : File={0}, Line={1}, Level={2}, Block={3}, Address={4:#x}".format(filename, line, level, block, address))
            entry = {'filename' : filename, 'line' : line, 'level' : level, 'block' : block, 'address' : address }
        return entry

    def findLinkAddressOfSymbol(self, symbol, scope=None, includeEndAddress=False):
        rv = None
        ea = None
        self.logger.debug("findLinkAddressOfSymbol(symbol={0}, iea={1} )".format(symbol, includeEndAddress))
        for cdb in self.cdb:
            for line in cdb['lines']:
                # Link Address
                entry = self.parseLinkAddressOfSymbolScopeGlobal(line)
                if entry != None:
                    if entry['name'] == symbol:
                        rv = entry
                else:
                    entry = self.parseLinkAddressOfSymbolScopeFile(line)
                    if (entry != None) and (entry['name'] == symbol):
                        rv = entry
                        
                # End Address
                if includeEndAddress:           
                    entry = self.parseSymbolEndAddressRecordScopeGlobal(line)
                    if entry != None:
                        if entry['name'] == symbol:
                            ea = entry
                    else:
                        entry = self.parseSymbolEndAddressRecordScopeFile(line)
                        if (entry != None) and (entry['name'] == symbol):
                            ea = entry

                # Early break if possible
                if ( ( (includeEndAddress == False) and (rv != None) ) or
                     ( (includeEndAddress == True) and (rv != None) and (ea != None) ) ):
                    
                    if includeEndAddress:
                        rv['endaddress'] = ea['address']

                    self.logger.debug(" {0}".format(rv))
                    return rv
        return rv

    def findBaseSymbolOfAddress(self, searchaddress):
        self.logger.debug("addressToFunction({0})".format(searchaddress))
        if searchaddress == None:
            return None

        bestMatch = None        
        for cdb in self.cdb:
            for line in cdb['lines']:
                entry = self.parseLinkAddressOfSymbolScopeGlobal(line)
                if entry != None:
                    if entry['address'] <= searchaddress:
                        if (bestMatch == None):
                            bestMatch = entry 
                        elif (entry['address'] > bestMatch['address']):
                            bestMatch = entry 
                entry = self.parseLinkAddressOfSymbolScopeFile(line)
                if entry != None:
                    if entry['address'] <= searchaddress:
                        if (bestMatch == None) or (entry['address'] > bestMatch['address']):
                            bestMatch = entry
        self.logger.debug("  bestMatch = {0}".format(bestMatch))
             
        return bestMatch

    def ClineToAddress(self, filename, linenumber):
        self.logger.debug("# ClineToAddress({0}, {1})".format(filename, linenumber))
            
        further = None
        exact = None
        for cdb in self.cdb:
            for line in cdb['lines']:
                entry = self.parseCline(line)
                if entry != None and basename(entry['filename']) == basename(filename):
                    if (entry['line'] == linenumber):
                        exact = entry
                        self.logger.debug("exact line={0}".format(entry['line']))
                    elif entry['line'] > linenumber:
                        if further == None:
                            further = entry
                            self.logger.debug("further line={0}".format(entry['line']))
                        elif (entry['line'] < further['line']):
                            further = entry
                            self.logger.debug("further line={0}".format(entry['line']))
#                         act = {'level' : entry['level'], 'block': entry['block'], 'address': entry['address']}

        match = None
        if (exact == None) and (further != None):
            match = further 
            match['address_begin'] = further['address']
            match['address_end'] = further['address']
        elif (exact != None) and (further == None):
            match = exact
            match['address_begin'] = exact['address']
            match['address_end'] = exact['address']
        elif (exact != None) and (further != None):
            match = exact
            match['address_begin'] = exact['address']
            match['address_end'] = further['address'] - 1
                
        if match != None:
            self.logger.debug("  address = {0:#x}".format(match['address']))
        else:
            self.logger.debug("  address = None")
                
        return match

    def symbolToCline(self, symbol, scope=None):
        self.logger.debug("symbolToCline({0})".format(symbol))
        address = self.findLinkAddressOfSymbol(symbol, scope)
        self.logger.info("findLinkAddressOfSymbol({}) is {}".format(symbol, address))
        if address != None:
            return self.addressToCline(address['address'])

        return None

    def addressToCline(self, searchaddress, exactmatch=False):
        self.logger.debug("addressToCline({0:#x})".format(searchaddress))
        if searchaddress == None:
            return None
        before = None
        exact = None
        after = None
        for cdb in self.cdb:
            self.logger.debug("cdbfile:{}".format(cdb['cdbfile']))
            for line in cdb['lines']:
                entry = self.parseCline(line)
                if entry != None:
                    if entry['address'] < searchaddress:
                        if before == None:
                            before = entry
                        elif entry['address'] > before['address']:
                            before = entry
                    elif entry['address'] == searchaddress:
                        if exact == None:
                            exact = entry
                        else:
                            self.logger.warning("more than one exact match for address {0:#x}".format(entry['address']))
                    elif entry['address'] > searchaddress:
                        if after == None:
                            after = entry
                        elif entry['address'] < after['address']:
                            after = entry
                    else:
                        raise RuntimeError("Address {0:#x} evaluated not as smaller nor equal nor bigger as searchaddress {1:#x}".format(entry['address'], searchaddress))
        if exact != None:
            self.logger.debug("addressToCline() -> exact:{0}".format(exact))
            return exact
        elif exactmatch == False:
            self.logger.debug("addressToCline() -> close:{0}".format(after))
            return after
        else:
            self.logger.warning("addressToCline() -> None")
            return None
                        
    def getScopeForAddress(self, searchaddress):
        self.logger.debug("getScopeForAddress({0})".format(searchaddress))
        if searchaddress == None:
            return None

        bestMatch = None        
        for cdb in self.cdb:
            for line in cdb['lines']:
                entry = self.parseLinkAddressOfSymbolScopeGlobal(line)
                if entry != None:
                    if entry['address'] <= searchaddress:
                        if (bestMatch == None):
                            bestMatch = entry 
                        elif (entry['address'] > bestMatch['address']):
                            bestMatch = entry 
                entry = self.parseLinkAddressOfSymbolScopeFile(line)
                if entry != None:
                    if entry['address'] <= searchaddress:
                        if (bestMatch == None) or (entry['address'] > bestMatch['address']):
                            bestMatch = entry
        self.logger.debug("  bestMatch = {0}".format(bestMatch))
             
        return bestMatch
                          
    def getEndScope(self, scope):
        for cdb in self.cdb:
            for line in cdb['lines']:
                if scope['scope'] == 'global':
                    entry = self.parseSymbolEndAddressRecordScopeGlobal(line)
                    if entry != None:
                        if entry['name'] == scope['name']:
                            return entry
                else:
                    entry = self.parseSymbolEndAddressRecordScopeFile(line)
                    if entry != None:
                        if (entry['file'] == scope['file']) and (entry['name'] == scope['name']):
                            return entry
        return None

    def getBreaksInRange(self, begin, end):
        breaks = []
        for cdb in self.cdb:
            for line in cdb['lines']:
                entry = self.parseCline(line)
                if entry != None:
                    if (entry['address'] >= begin) and (entry['address'] <= end):
                        breaks.append(entry)
        return breaks
    
    def getBreaksInContext(self, address):
        self.logger.info("getBreaksInContext({0})".format(address))
        scope = self.getScopeForAddress(address)
        if scope != None:
            endscope = self.getEndScope(scope)
            breaks = self.getBreaksInRange(scope['address'], endscope['address'])
            self.logger.debug(" => {0}".format(breaks))
            return breaks
        else:
            self.logger.debug(" => None")
        return None
    
if __name__ == '__main__':
    logger = logging.getLogger('openmsxgdb.cdbreader')
    logger.setLevel(logging.DEBUG)
    h = logging.StreamHandler()
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    h.setFormatter(formatter)
    logger.addHandler(h)

    logger.info("going to read CDB data")
    a=cdbreader(cdbfiles=['example/test.cdb'], sourcedirs=['.'], verbose=True)
    #print("modules:{0}".format(a.getmodules()))
    #addr = a.ClineToAddress('test.c', 62)
    #print("match address={0:#x} address_begin={1:#x} address_end={2:#x}".format(addr['address'], addr['address_begin'], addr['address_end'] ))

    breaks = a.getBreaksInContext(0x4202)
    if breaks != None:
        logger.info("breaks = ")
        for bp in breaks:
            logger.info("  {0}".format(bp))
        
#     rv = a.findLinkAddressOfSymbol('main')
#     if rv == None:
#         print ("Symbol not found")
#     else:
#         print ("Address of 'main' is {0}".format(rv['address']))
#         cline = a.addressToCline(rv['address'])
#         if cline == None:
#             print ("No matching cline found")
#         else:
#             print ("Found cline at : {0}:{1} (address={2})".format(cline['filename'], cline['line'], cline['address']))
#         
#     #print("alines:{0}".format(a.aline))
#     for addr in range(0x4100, 0x4200):
#         csrc, cline = a.addressToCline(addr)
#         asrc, aline = a.addressToAsmline(addr)
#         print("{0:#x} {1}:{2} {3}:{4}".format(addr, csrc, cline, asrc, aline))
