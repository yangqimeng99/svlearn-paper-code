# -*- coding: utf-8 -*-
#!/usr/bin/env python3
"""
Created on Thu Mar 29 10:21:54 2018
@Mail: minnglee@163.com
@Author: Ming Li
"""

import sys,os,logging,click
import gzip,re

logging.basicConfig(filename='{0}.log'.format(os.path.basename(__file__).replace('.py','')),
                    format='%(asctime)s: %(name)s: %(levelname)s: %(message)s',level=logging.DEBUG,filemode='w')
logging.info(f"The command line is:\n\tpython3 {' '.join(sys.argv)}")

def LoadNameDict(File):
    '''
    1       NC_019458.2
    2       NC_019459.2
    '''
    Dict = {}
    for line in File:
        line = line.strip().split()
        Dict[line[1]] = line[0]
    return Dict
@click.command()
@click.option('-i','--input',help='Input file',type=str,required=True)
@click.option('--fa',help='The input is fasta file',is_flag=True)
@click.option('--gff',help='The input is gff file',is_flag=True)
@click.option('-n','--name',type=click.File('r'),help='Name file',required=True)
@click.option('-o','--output',type=click.File('w'),help='Output file',required=True)
def main(input,fa,gff,name,output):
    INPUT = os.popen(f'less {input}').readlines()
    NameDict = LoadNameDict(name)
    if fa:
        for line in INPUT:
            line = line.strip()
            if line.startswith('>'):
                OldChrName = line.split()[0][1:]
                if OldChrName in NameDict: output.write(f'>{NameDict[OldChrName]}\n')
                else: output.write(f'>{OldChrName}\n')
            else:
                output.write(f'{line}\n')
    elif gff:
        for line in INPUT:
            line = line.strip()
            if line.startswith('#'):
                output.write(f'{line}\n')
            else:
                LineList = line.split('\t')
                if LineList[0] in NameDict :
                    Info = '\t'.join(LineList[1:])
                    output.write(f'{NameDict[LineList[0]]}\t{Info}\n')
                else: output.write(f'{line}\n')
if __name__ == '__main__':
    main()
