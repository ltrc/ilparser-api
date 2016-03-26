#! /usr/bin/env python

import re
import sys
import socket
import argparse
import StringIO
import threading
from ilparser import ilparser
from ilparser import rawtoconll
from converter_indic import wxConvert
from argparse import RawTextHelpFormatter

_MAX_BUFFER_SIZE_ = 102400 #100KB

class ClientThread(threading.Thread):
    def __init__(self, ip, port, clientsocket, args, parser):
        threading.Thread.__init__(self)
        self.ip = ip
        self.port = port
        self.args = args
        self.parser = parser
        self.csocket = clientsocket
        #print "[+] New thread started for "+ip+":"+str(port)

    def run(self):
        #print "Connection from : "+ip+":"+str(port)
        data = self.csocket.recv(_MAX_BUFFER_SIZE_)
        #print "Client(%s:%s) sent : %s"%(self.ip, str(self.port), data)
        fakeInputFile = StringIO.StringIO(data)
        fakeOutputFile = StringIO.StringIO("")
        processInput(fakeInputFile, fakeOutputFile, self.args, self.parser)
        fakeInputFile.close()
        self.csocket.send(fakeOutputFile.getvalue())
        fakeOutputFile.close()
        self.csocket.close()
        #print "Client at "+self.ip+" disconnected..."

def processInput(ifp, ofp, args, parser):
    convertor = wxConvert(order='wx2utf', lang='hin', format_='conll')
    sentences = ifp.read().split('\n\n')
    ifp.close()
    for sentence in sentences:
        if not sentence.strip():continue
        sentence = "\n".join(list(rawtoconll.toConll(sentence)))
        sentence = convertor.convert(sentence)
        out_parse = parser.getParse([sentence], sflag=False)
        if out_parse:
                ofp.write("%s\n\n" %(out_parse[0]))

if __name__ == '__main__':
    # parse command line arguments
    parser = argparse.ArgumentParser(prog="ilparser_hin",
                                    description="Parser for Hindi Language",
                                    formatter_class=RawTextHelpFormatter)
    parser.add_argument('--input', metavar='input', dest="infile", type=argparse.FileType('r'), default=sys.stdin, help="<input-file>")
    parser.add_argument('--output', metavar='output', dest="outfile", type=argparse.FileType('w'), default=sys.stdout, help="<output-file>")
    parser.add_argument('--plot', action='store_true', dest="plot", help="set this flag to plot output parse trees")
    parser.add_argument('--dir', metavar='directory', dest="out_dir", help="directory for plotted parse trees")
    parser.add_argument('--beams', type=int, default=1, dest="beams", help="number for beams for beam search decoding")
    parser.add_argument('--daemonize', dest='isDaemon', help='Do you want to daemonize me?', action='store_true', default = False)
    parser.add_argument('--port', type=int, dest='daemonPort', default=5000, help='Specify a port number')
    args = parser.parse_args()

    sys.stderr.write("Loading Models ....")
    parser = ilparser(out_dir=args.out_dir,plot=args.plot,conll=True,beamWidth=args.beams,lang='hin')
    sys.stderr.write("...done\n")

    if args.isDaemon:
        host = "0.0.0.0" #Listen on all interfaces
        port = args.daemonPort #Port number

        tcpsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        tcpsock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

        tcpsock.bind((host,port))
        sys.stderr.write('Listening at %d\n' %port)

        while True:
            tcpsock.listen(4)
            #print "nListening for incoming connections..."
            (clientsock, (ip, port)) = tcpsock.accept()

            #pass clientsock to the ClientThread thread object being created
            newthread = ClientThread(ip, port, clientsock, args, parser)
            newthread.start()
    else:
        processInput(args.infile, args.outfile, args, parser)

    # close files
    args.infile.close()
    args.outfile.close()
