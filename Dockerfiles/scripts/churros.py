#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import argparse
import pathlib
import pandas as pd


def print_and_exec_shell(command):
    print (command)
    os.system(command)

def check_file(file):
    if os.path.isfile(file):
        pass
    else:
        print ("Error: " + file + " does not exist.")
        exit()

def check_dir(dir):
    if os.path.isdir(dir):
        pass
    else:
        print ("Error: " + dir + " does not exist.")
        exit()

def get_mapfile_postfix(mapparam):
    post = "-bowtie2" + mapparam.replace(' ', '')
    return post

def do_qualitycheck_fastq(fastq, fastqcdir, fastpdir):
    name = os.path.basename(fastq)
    print_and_exec_shell('fastqc -t 4 -o ' + fastqcdir + ' ' + fastq)
    print_and_exec_shell('fastp -w 4 -q 15 -n 5 -i ' + fastq
                         + ' -o ' + fastpdir + name + '.fastq.gz'
                         + ' -h ' + fastpdir + name + '.fastp.html'
                         + ' -j ' + fastpdir + name + '.fastp.json')

def do_fastqc(chdir, samplelist):
    fastqcdir = chdir + "/fastqc/"
    fastpdir =  chdir + "/fastp/"
    os.makedirs(fastqcdir, exist_ok=True)
    os.makedirs(fastpdir, exist_ok=True)

    df = pd.read_csv(samplelist, sep="\t", header=None)
    for index, row in df.iterrows():
        if (len(row)<2 or row[1] == ""):
            print ("Error: specify fastq file in " + samplelist + ".")
            exit()

        prefix = row[0]
        fq1 = row[1]
        for fastq in fq1.split(","):
            do_qualitycheck_fastq(fastq, fastqcdir, fastpdir)

        if (len(row)>2): # for paired-end
            fq2 = row[2]
            for fastq in fq2.split(","):
                do_qualitycheck_fastq(fastq, fastqcdir, fastpdir)


def do_mapping(args, samplelist, post, build, chdir):
    if args.mpbl:
        param_churros_mapping = "-D " + chdir + " -p " + str(args.threads) + " -m"
    else:
        param_churros_mapping = "-D " + chdir + " -p " + str(args.threads)

    # exec
    df = pd.read_csv(samplelist, sep="\t", header=None)
    for index, row in df.iterrows():
        if (len(row)<2 or row[1] == ""):
            print ("Error: specify fastq file in " + samplelist + ".")
            exit()

        prefix = row[0]
        fq1 = row[1]
        fq2 = ""
        pair = ""
        if (len(row)>2): # for paired-end
            fq2 = row[2]
            pair = "-p"
            fastq = "-1 " + fq1 + " -2 " + fq2
        else:
            fastq = fq1

        head = prefix + post + "-" + build

        print_and_exec_shell('churros_mapping ' + param_churros_mapping + ' exec "' + fastq + '" ' + prefix  + ' ' + build + ' ' + args.Ddir)

    # header
    print_and_exec_shell('churros_mapping ' + param_churros_mapping + ' header "' + fastq + '" ' + prefix  + ' ' + build + ' ' + args.Ddir + ' > ' + chdir + '/churros.QCstats.tsv')

    # stats
    df = pd.read_csv(samplelist, sep="\t", header=None)
    for index, row in df.iterrows():
        prefix = row[0]
        fq1 = row[1]
        print_and_exec_shell('churros_mapping ' + param_churros_mapping + ' stats "' + fq1 + '" ' + prefix  + ' ' + build + ' ' + args.Ddir + ' >> ' + chdir + '/churros.QCstats.tsv')

def make_samplepairlist_withflen(samplepairlist, post, build, chdir):
    samplepairlist_withflen = chdir + "/churros.samplepairlist.withflen.txt"
    if(os.path.isfile(samplepairlist_withflen)):
        os.remove(samplepairlist_withflen)

    df = pd.read_csv(samplepairlist, sep=",", header=None)
    for index, row in df.iterrows():
        chip  = row[0]
        input = row[1]
        label = row[2]
        mode  = row[3]

        sspstats = pd.read_csv(chdir + '/sspout/' + chip + post + '-' + build + '.stats.txt', sep="\t", header=0)
        flen = int(sspstats["fragment length"])

        with open(samplepairlist_withflen, 'a') as f:
            print(chip + "," + input + "," +label + "," +mode + "," + str(flen), file=f)

    return samplepairlist_withflen

def exec_churros(args):
    samplelist = args.samplelist
    samplepairlist = args.samplepairlist
    build = args.build
    Ddir = args.Ddir
    chdir = args.outputdir

    check_file(samplelist)
    check_file(samplepairlist)

    # To absolute path
    samplelist = pathlib.Path(samplelist).resolve()
    samplepairlist = pathlib.Path(samplepairlist).resolve()

    mapparam = args.mapparam
    post = get_mapfile_postfix(mapparam)

    os.makedirs(chdir, exist_ok=True)

    ### FASTQC
    if args.nofastqc == False:
        do_fastqc(chdir, samplelist)

    ## churros_mapping
    do_mapping(args, samplelist, post, build, chdir)

    ## make samplepairlist_withflen
    samplepairlist_withflen = make_samplepairlist_withflen(samplepairlist, post, build, chdir)

    ## churros_callpeak
    param_macs=' -b bam -p ' + str(args.threads) + ' -q ' + str(args.qval) + ' -d ' + args.macsdir + ' -D ' + chdir
    if os.path.isfile(samplepairlist_withflen):
        print_and_exec_shell('churros_callpeak' + param_macs + ' ' + samplepairlist_withflen + ' ' + build)
    else:
        print_and_exec_shell('churros_callpeak' + param_macs + ' ' + samplepairlist + ' ' + build)

    ### MultiQC
    print_and_exec_shell('multiqc -m fastqc -m fastp -m bowtie2 -m macs2 -f -o ' + chdir + ' ' + chdir)

    ### generate P-value bedGraph
    if args.outputpvalue:
        print ("generate Pvalue bedGraph file...")
        gt = Ddir + '/genometable.txt'
        print_and_exec_shell('churros_genPvalwig -D ' + chdir + ' ' + str(samplepairlist) + ' drompa+.pval ' + build + ' ' + gt)

    ### make corremation heatmap
    if args.mpbl:
        param_churros_compare = "-m"
    else:
        param_churros_compare = ""

    print_and_exec_shell('churros_compare ' + param_churros_compare + ' ' + str(samplelist) + ' ' + build)

    ### make pdf files
    print ("generate pdf files by drompa+...")

    if args.mpbl:
        param_churros_visualize = "-D " + chdir + " -m"
    else:
        param_churros_visualize = "-D " + chdir

    pdfdir = "pdf"
    print_and_exec_shell('churros_visualize '+ param_churros_visualize + ' ' + chdir + '/' + args.macsdir + '/samplepairlist.txt ' + pdfdir + '/drompa+.macspeak ' + build + ' ' + Ddir)
    print_and_exec_shell('churros_visualize '+ param_churros_visualize + ' -b 5000 -l 8000 -P "--scale_tag 100" ' + str(samplepairlist) + ' ' + pdfdir + '/drompa+.bin5M ' + build + ' ' + Ddir)
    print_and_exec_shell('churros_visualize '+ param_churros_visualize + ' -b 5000 -l 8000 -p -P "--pthre_enrich 3 --scale_pvalue 3" ' \
                         + str(samplepairlist) + ' ' + pdfdir + '/drompa+.pval.bin5M ' + build + ' ' + Ddir)
    print_and_exec_shell('churros_visualize '+ param_churros_visualize + ' -G ' + str(samplepairlist) + ' ' + pdfdir + '/drompa+ ' + build + ' ' + Ddir)

if(__name__ == '__main__'):
    parser = argparse.ArgumentParser()
    parser.add_argument("samplelist", help="sample list", type=str)
    parser.add_argument("samplepairlist", help="ChIP/Input pair list", type=str)
    parser.add_argument("build", help="genome build (e.g., hg38)", type=str)
    parser.add_argument("Ddir", help="directory of reference data", type=str)
    parser.add_argument("--cram", help="output as CRAM format (default: BAM)", action="store_true")
    parser.add_argument("-b", "--binsize", help="binsize of parse2wig+ (default: 100)", type=int, default=100)
    parser.add_argument("--mpbl", help="consider genome mappability in drompa+", action="store_true")
    parser.add_argument("--nofastqc", help="omit FASTQC", action="store_true")
    parser.add_argument("-q", "--qval", help="threshould of MACS2 (default: 0.05)", type=float, default=0.05)
    parser.add_argument("--macsdir", help="output direcoty of macs2 (default: 'macs2')", type=str, default="macs")
    parser.add_argument("-f", "--format", help="output format of parse2wig+ 0: compressed wig (.wig.gz)\n 1: uncompressed wig (.wig)\n 2: bedGraph (.bedGraph) \n 3 (default): bigWig (.bw)", type=int, default=3)
    parser.add_argument("--mapparam", help="parameter of bowtie2 (shouled be quated)", type=str, default="")
    parser.add_argument("-p", "--threads", help="number of CPUs (default: 12)", type=int, default=12)
    parser.add_argument("--outputpvalue", help="output ChIP/Input -log(p) distribution as a begraph format", action="store_true")
    parser.add_argument("-D", "--outputdir", help="output directory (default: 'Churros_result')", type=str, default="Churros_result")

    args = parser.parse_args()
    print(args)

    exec_churros(args)
    print ("churros finished.")
