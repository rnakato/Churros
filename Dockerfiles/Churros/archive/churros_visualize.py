#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import argparse
import pathlib
import pandas as pd

def print_and_exec_shell(command):
    print (command)
    os.system(command)

def echo_and_print_and_exec_shell(command, logfile):
    os.system("echo '" + command + "' >" + logfile)
    print_and_exec_shell(command)

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

def setlinesize(args):
    if args.preset == "scer":
        linesize = 200
    else:
        linesize = 1000
    if args.linesize > 0:
        linesize = args.linesize

    return linesize

def setparam(args):
    Ddir = args.Ddir
    linesize = setlinesize(args)

    if args.preset == "scer":
        gene = "/opt/DROMPAplus/data/S_cerevisiae/SGD_features.tab"
        arsfile = "/opt/DROMPAplus/data/S_cerevisiae/ARS-oriDB_scer.txt"
        param = "--scale_ratio 4 --ls " + str(linesize) + " --sm 10 --lpp 3 -g " + gene + " --gftype 2 --ars " + arsfile
#    elif args.preset == "T2T":
#        gene = Ddir + "/chm13v2.refFlat"
#        param = " --ls " + str(linesize) + " -g " + gene
    else:
        gene = Ddir + "/gtf_chrUCSC/chr.gene.refFlat"
        param = " --ls " + str(linesize) + " -g " + gene
    gt = Ddir + "/genometable.txt"
    check_file(gt)
    param += " --gt " + gt

    if args.drompaparam != "":
        param += " " + args.drompaparam + " "

    return param

def do_churros_visualize(args):
    samplepairlist = args.samplepairlist
    build = args.build
    Ddir = args.Ddir
    chdir = args.outputdir + "/" + build + "/"

    check_file(samplepairlist)

    # To absolute path
    samplepairlist = pathlib.Path(samplepairlist).resolve()

    os.makedirs(chdir, exist_ok=True)

    pdir = chdir + "/bigWig/" + args.d + "/"

#    if args.wigformat == 0:
 #       fileext = "wig.gz"
 #   elif args.wigformat == 1:
 #       fileext = "wig"
 #   elif args.wigformat == 2:
 #       fileext = "bedGraph"
 #   elif args.wigformat == 3:
    fileext = "bw"
  #  else:
   #     print("Error: specify [0-3] for '-f' option.")
   #     exit()

    if args.postfix != "":
        post = args.postfix
    else:
        if args.nompbl:
            post = ""
        else:
            post = ".mpbl"

    # DROMPA+ param
    pdfdir = chdir + "/pdf"
    os.makedirs(pdfdir, exist_ok=True)
    logdir = chdir + "/log/pdf/"
    os.makedirs(logdir, exist_ok=True)

    param = setparam(args)

    if args.G:
        visualize_GV(args, samplepairlist, pdir, pdfdir, logdir, fileext, post, Ddir, build)
    elif args.enrich:
        visualize_PCENRICH(args, param, samplepairlist, pdir, pdfdir, logdir, fileext, post, Ddir)
    else:
        visualize_PCSHARP(args, param, samplepairlist, pdir, pdfdir, logdir, fileext, post, Ddir, chdir)

def is_exist_input(samplepairlist):
    df = pd.read_csv(samplepairlist, sep=",", header=None)
    df.fillna("", inplace=True)

    nInput = 0
    for index, row in df.iterrows():
        chip  = row[0]
        input = row[1]
        label = row[2]

        if input != "":
            nInput += 1

    if nInput == 0:
        return False
    else:
        return True

def visualize_GV(args, samplepairlist, pdir, pdfdir, logdir, fileext, post, Ddir, build):
    param = " " + args.drompaparam + " "
    ideogram = "/opt/DROMPAplus/data/ideogram/" + build + ".tsv"
    GC = Ddir + "/GCcontents/"
    GD = Ddir + "/gtf_chrUCSC/genedensity"
    gt = Ddir + "/genometable.txt"
    check_file(gt)

    if args.preset == "T2T":
        param += " --gt " + gt
    else:
        param += " --gt " + gt
        if os.path.isfile(ideogram):
            param += " --ideogram " + ideogram
        else:
            print (ideogram + " does not exist. skipping.")
        if os.path.isdir(GC):
            param += " --GC " + GC + " --gcsize 500000"
        else:
            print (GC + " does not exist. skipping.")
        if os.path.isdir(GD):
            param += " --GD " + GD + " --gdsize 500000"
        else:
            print (GD + " does not exist. skipping.")

    df = pd.read_csv(samplepairlist, sep=",", header=None)
    df.fillna("", inplace=True)

    if not is_exist_input(samplepairlist):
        print ("No ChIP sample with the input sample. Skipped.")
        return

    sGV = ""
    for index, row in df.iterrows():
        chip  = row[0]
        input = row[1]
        label = row[2]

        if input != "":
            sGV += " -i " + pdir + chip  + post + ".100000." + fileext + "," \
                          + pdir + input + post + ".100000." + fileext + "," \
                          + label
        else:
            print ("sample " + chip + " does not have the input sample. skipped..")

    head = os.path.basename(args.prefix)
    outputprefix =  pdfdir + "/" + head + ".GV.100000"
    logfile = logdir + head + ".GV.100000.log"

    command = "drompa+ GV " + param + " " + sGV + " -o " + outputprefix + " | tee -a " + logfile
    echo_and_print_and_exec_shell(command, logfile)


def visualize_PCENRICH(args, param, samplepairlist, pdir, pdfdir, logdir, fileext, post, Ddir):
    if args.pvalue:
        param += " --showpenrich 1"
    if args.logratio:
        param += " --showratio 2"
    if args.preset != "scer":
        param += " --showchr "

    df = pd.read_csv(samplepairlist, sep=",", header=None)
    df.fillna("", inplace=True)

    if not is_exist_input(samplepairlist):
        print ("No ChIP sample with the input sample. Skipped.")
        return

    s = ""
    for index, row in df.iterrows():
        chip  = row[0]
        input = row[1]
        label = row[2]
        if input != "":
            s += " -i " + pdir + chip  + post + "." + str(args.binsize) + "." + fileext + "," \
                        + pdir + input + post + "." + str(args.binsize) + "." + fileext + "," \
                        + label
        else:
            print ("sample " + chip + " does not have the input sample. skipped..")

    head = os.path.basename(args.prefix)
    outputprefix =  pdfdir + "/" + head + ".PCENRICH." + str(args.binsize)
    logfile_prefix = logdir + head + ".PCENRICH." + str(args.binsize)

    command = "drompa+ PC_ENRICH " + param + " " + s + " -o " + outputprefix + " | tee -a " + logfile_prefix + ".log"
    echo_and_print_and_exec_shell(command, logfile_prefix + ".log")
    command = "drompa+ PC_ENRICH " + param + " --callpeak " + s + " -o " + outputprefix + ".callpeak | tee -a " + logfile_prefix + ".callpeak.log"
    echo_and_print_and_exec_shell(command, logfile_prefix + ".callpeak.log")

    if args.preset != "scer":
        os.remove(outputprefix + ".pdf")
        os.remove(outputprefix + ".callpeak.pdf")


def visualize_PCSHARP(args, param, samplepairlist, pdir, pdfdir, logdir, fileext, post, Ddir, chdir):
    if args.pvalue:
        param += " --showctag 0 --showpenrich 1"

    param += " --callpeak"
    if args.preset != "scer":
        param += " --showchr "

    df = pd.read_csv(samplepairlist, sep=",", header=None)
    df.fillna("", inplace=True)
    s = ""
    for index, row in df.iterrows():
        chip  = row[0]
        input = row[1]
        label = row[2]
        peak = ""
        if (len(row)>4):
            peak = chdir + "/" + row[4]
            if os.path.isfile(peak):
                pass
            else:
                print ("Warning: " + peak + " does not exist. Using internal peak call.")
                peak = ""

        if input != "":
            s += " -i " + pdir + chip  + post + "." + str(args.binsize) + "." + fileext + "," \
                        + pdir + input + post + "." + str(args.binsize) + "." + fileext + "," \
                        + label + "," + peak
        else:
            s += " -i " + pdir + chip + post + "." + str(args.binsize) + "." + fileext + ",," \
                        + label + "," + peak

    head = os.path.basename(args.prefix)
    outputprefix =  pdfdir + "/" + head + ".PCSHARP." + str(args.binsize)
    logfile = logdir + head + ".PCSHARP." + str(args.binsize) + ".log"

    command = "drompa+ PC_SHARP " + param + " " + s + " -o " + outputprefix + " | tee -a " + logfile
    echo_and_print_and_exec_shell(command, logfile)

    if args.preset != "scer":
        os.remove(outputprefix + ".pdf")
    print_and_exec_shell("rm " + outputprefix + "*.peak.bed " + outputprefix + "*.peak.tsv")


if(__name__ == '__main__'):
    parser = argparse.ArgumentParser()
    parser.add_argument("samplepairlist", help="ChIP/Input pair list", type=str)
    parser.add_argument("prefix", help="output prefix (directory will be omitted)", type=str)
    parser.add_argument("build", help="genome build (e.g., hg38)", type=str)
    parser.add_argument("Ddir", help="directory of reference data", type=str)
#    parser.add_argument("-f", "--wigformat", help="input file format 0: compressed wig (.wig.gz)\n 1: uncompressed wig (.wig)\n 2: bedGraph (.bedGraph) \n 3 (default): bigWig (.bw)", type=int, default=3)
    parser.add_argument("-b", "--binsize", help="binsize of parse2wig+ (default: 100)", type=int, default=100)
    parser.add_argument("-l", "--linesize", help="line size for each page (kbp, defalt: 1000)", type=int, default=-1)
    parser.add_argument("--nompbl", help="do not consider genome mappability", action="store_true")
    parser.add_argument("-d", help="directory of bigWig files (default: 'TotalReadNormalized/')", type=str, default="TotalReadNormalized/")
    parser.add_argument("--postfix", help="param string of parse2wig+ files to be used (default: '.mpbl')", type=str, default="")
    parser.add_argument("--pvalue", help="show p-value distribution instead of read distribution", action="store_true")
    parser.add_argument("--bowtie1", help="specified bowtie1", action="store_true")
    parser.add_argument("-P","--drompaparam", help="additional parameters for DROMPA+ (shouled be quated)", type=str, default="")
    parser.add_argument("-G", help="genome-wide view (100kbp)", action="store_true")
    parser.add_argument("--enrich", help="PC_ENRICH: show ChIP/Input ratio (preferred for yeast)", action="store_true")
    parser.add_argument("--logratio", help="(for PC_ENRICH) show log-scaled ChIP/Input ratio", action="store_true")
    parser.add_argument("--preset", help="Preset parameters for mapping reads ([scer|T2T])", type=str, default="")
    parser.add_argument("-D", "--outputdir", help="output directory (default: 'Churros_result')", type=str, default="Churros_result")

    args = parser.parse_args()
#    print(args)

    if args.preset != "":
        if args.preset != "scer" and args.preset != "T2T":
            print ("Error: specify [scer|T2T] for --preset option.")
            exit()

    do_churros_visualize(args)
    print ("churros_visualize finished.")
