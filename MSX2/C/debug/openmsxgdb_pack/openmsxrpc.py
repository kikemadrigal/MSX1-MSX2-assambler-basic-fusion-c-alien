#!/usr/bin/env python3
#
# OpenMSX GDB
#
# Copyright (c) 2015-2016  Erik Maas
#    
# SPDX-License-Identifier: MIT

import os
import time
import socket
import threading
import pwd
import xml.etree.ElementTree as ET
import logging

class History():
    def __init__(self):
        self.history = []
        self.flush()

    def record(self, message):
        ts = time.time()
        self.history.append({'timestamp' : ts, 'message': message})
#         self.dump()

    def find(self, tag=None):
        for entry in self.history:
            if entry['message'].tag == tag:
                val = entry['message']
                self.history.remove(entry)
                return val
        return None

    def flush(self, tag=None):
        if tag == None:
            self.history = []
        else:
            logger.warning("Partial flush not implemented yet")
            pass
        
    def dump(self):
        logger.info("=== dump start ===")
        for entry in self.history:
            logger.info("ts:{0} tag={1} message={2}".format(entry['timestamp'], entry['message'].tag, ET.tostring(entry['message'])))
        logger.info("=== dump end ===")

class OpenmsxRpc(threading.Thread):
    def __init__(self, callback=None):
        self.control = None
        self.socket = None
        self.active = False
        self.quit = False
        self.callback = callback
        self.logger = logging.getLogger('openmsxgdb.openmsx_rpc')
        threading.Thread.__init__(self)
        self.start()
        self.history = History()
    
    def stop(self, wait_for_deactive=True):
        logging.info("openmsxrpc.stop(wait_for_deactive={})".format(wait_for_deactive))
        self.quit = True
        # Workaround to get the running thread awake to commit suicide
        self.command("message {gdb disconnected}", wait_for_deactive)
        if wait_for_deactive:
            logging.info("Waiting for openmsxrpc thread to stop")
            while self.active:
                time.sleep(0.1)
        
    def isConnected(self):
        return self.active
        
    def run(self):
        data = ""
        message = None
        
        while self.quit == False:
            if self.socket:
                data = data + self.socket.recv(1024).decode('utf-8')
                lastNewLine = data.rfind('\n')
                lines = data[ : lastNewLine ].split('\n')
                data = data[ lastNewLine + 1 : ]
                for line in lines:
                    # if self.verbose:
                        # print("log: '{0}'".format(line))
                    line = line.strip()
                    if line != "":
                        if self.active == False:
                            if line == "<openmsx-output>":
                                self.active = True
                        else:
                            if message == None:
                                message = ""
                            message += line
        
                            try:
                                msg = ET.fromstring(message)
                                self.logger.info("in: {0}".format(message.strip()))
                                self.history.record(msg)
                                if self.callback != None:
                                    threading.Thread(target=self.callback, args=(msg,)).start()
                                message = None
                            except ET.ParseError:
                                # The XML data comes in line by line, multiline responses will fail until we collected all required lines.
                                # self.logger.warning("could not parse: [{0}]".format(message))
                                pass
                            except:
                                self.logger.error("exception while parsing: {0}".format(message))
                                raise

            # Sleeping is a bad habit, but will be solved later              
            time.sleep(0.01)
        self.active = False

    def open(self, launch=False):
        """\
        Open connection to OpenMSX. If launch is set to True, a new openMSX instance will be launched and connected. 
        """
        if launch == True:
            raise RuntimeError("Launching openMSX is not implemented yet")

        username =  pwd.getpwuid(os.getuid())[0]
        pid = self._getopenmsxpid()

        try:
            self.socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            socketname = '/tmp/openmsx-{0}/socket.{1}'.format(username, pid)
            self.socket.connect(socketname)
        except socket.error:
            raise RuntimeError("Unable to open socket")

        self.socket.sendall(bytes("<openmsx-control>\n", "utf-8"))
        self.command("message {gdb connected}")

    def _getopenmsxpid(self):
        """\
        Get the PID of a running openMSX instance.
        Currently only allow working if there is only one system wide instance.
        """
        pids = []
        for dirname in os.listdir('/proc'):
            if dirname == 'curproc':
                continue

            try:
                with open('/proc/{}/cmdline'.format(dirname), mode='rb') as fd:
                    content = fd.read().decode().split('\x00')
            except Exception:
                continue
            
            if "openmsx" in content[0]:
                pids.append(dirname)
                
        if len(pids) == 0:
            raise RuntimeError("No running OpenMSX found")
        elif len(pids) > 1:
            raise RuntimeError("More than one OpenMSX running, can not choose")

        return pids[0]

    def command(self, command=None, wait=True):
        """\
        Send a command to openMSX, by default wait for a response
        """
        while self.active == False:
            self.logger.error("openMSX RPC not connected")
            time.sleep(0.5)
        
        if command != None:
            # self.logger.info(command)
            self.history.flush()
            message = "<command>{0}</command>\n".format(command)
            self.socket.sendall(bytes(message, 'utf-8'))
            self.logger.info("out: {0}".format(message.strip()))
            
            if wait:
                while True:
                    reply = self.history.find("reply")
                    if reply != None:
                        # self.logger.info("result={0} text={1}".format(reply.attrib['result'], reply.text))
                        return {'result': reply.attrib['result'], 'data': reply.text }
                    else:
                        time.sleep(0.01)

        return None

def dummyCallback(msg):
    self.logger.info("Callback msg:{}".format(msg))

if __name__ == '__main__':
    # openMSX must be launched before running this code 
    o = OpenmsxRpc()
    o.open()
    while not o.isConnected():
        time.sleep(0.5)
    o.command("reset")
    time.sleep(0.6)
    o.command("openmsx_update enable led")
    time.sleep(0.6)
    o.command("debug list")
    value = o.command("debug read memory 0x4000")
    print("CPU:0x4000 byteval = {0}".format(value['data']))
    value = o.command("debug read {slotted memory} 0x44000")
    print("SLOT 1-0 0x4000 byteval = {0}".format(value['data']))
    time.sleep(4.0)
    print("done...")
    o.stop()
    