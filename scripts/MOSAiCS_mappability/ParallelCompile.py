
import sys, glob, re, subprocess, os, nws.sleigh, time

def run(cmd, dryrun):
    print cmd
    if not dryrun:
        subprocess.call(cmd, shell=True)

def get_fa_basenames():
    pat=re.compile('(.+)\.fa')
    fl=glob.glob('*.fa')
    return [pat.match(f).group(1) for f in fl]

def chkResults(l):
    quit=False
    for e in l:
       if e != None:
           quit=True
           print str(e)
    if quit:
       print 'Failure, quitting'
       sys.exit(1)

def setup_sleigh():
    '''This function sets up the parallel environment, and returns a handle to it, called a sleigh.'''
    # worker logging files will go here.
    logdir='/home2/jsr59/Work/Mappability_Map/logs'
    if not os.path.isdir(logdir):
        os.mkdir(logdir)
        
    # this needs to point to the location of this file
    modulepath='/home2/jsr59/Work/Mappability_Map/new_code'
    # this will be the name of the NWS and the log files.  It cannot contain blanks.
    wsnametemplate='JOEL_%s_%%04d'%time.ctime().replace(' ','_')
    
    if 'PBS_NODEFILE' in os.environ:
        nl = [n.strip() for n in open(os.environ['PBS_NODEFILE'])]

        # if running under PBS, start up workers using ssh, based on PBS allocation
        s=nws.sleigh.Sleigh(verbose=True, nwsHost='bulldogi.wss.yale.edu', wsNameTemplate=wsnametemplate,
                            launch=nws.sleigh.sshcmd, nodeList=nl, logDir=logdir, 
                            modulePath=modulepath)
    else:
        # if not, fork 4 local workers
        s=nws.sleigh.Sleigh(verbose=True, nwsHost='bulldogi.wss.yale.edu', wsNameTemplate=wsnametemplate,
                            workerCount=4, logDir=logdir,
                            modulePath=modulepath)
    return s
                                    
if __name__=='__main__':
    if len(sys.argv) != 2:
        print 'usage %s <merlen>' % sys.argv[0]
        sys.exit(1)
    merlen=sys.argv[1]
    fas = get_fa_basenames()
    dryrun=False

    s=setup_sleigh()
    print 's',str(s)
    print 'Step 1, convert each fa file to hash'
    jobs=['chr2hash %s.fa' % fa for fa in fas]
    chkResults(s.eachElem(run, [jobs], dryrun))
    
    print 'Step 2, find counts for cross product of chromosomes'
    jobs=['oligoFindPLFFile %s.fa %s.fa %s 0 0 1 1 > %sx%s.out' % (fa1, fa2, merlen, fa1, fa2) for fa2 in fas for fa1 in fas]
    chkResults(s.eachElem(run, [jobs], dryrun))

    print 'Step 3, merge counts'
    jobs=['mergeOligoCounts %s > %sb.out' % (' '.join(['%sx%s.out' % (f, fa) for f in fas]), fa) for fa in fas]
    chkResults(s.eachElem(run, [jobs], dryrun))

