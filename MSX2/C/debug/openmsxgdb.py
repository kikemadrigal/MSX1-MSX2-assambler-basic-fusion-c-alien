#!/usr/bin/env python3

"""
A really simple script just to demonstrate packaging
"""

import argparse
import textwrap
import time
import os
import sys
import string
import re
import logging
from os.path import basename,dirname

import sys, os
from openmsxgdb_pack import gdbconsole

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

if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, description='OpenMSX GDB debugger', epilog=description)
    parser.add_argument('program', nargs='?', help='executable to debug')
    parser.add_argument('--sourcedir', action='append', help='Directories to scan for c and assembly sources, required if sources are not in the location of the cdb file or the current working directory')
    parser.add_argument('--version', action='version', version="$(prog)s 0.0")
    parser.add_argument('-fullname', action='store_true')
    parser.add_argument('-q', action='store_true')
    args = parser.parse_args()

    g = gdbconsole.GdbConsole(program=args.program, sourcedir=args.sourcedir)
    g.console()
