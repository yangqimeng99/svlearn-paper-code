# -*- coding: utf-8 -*-
"""
Created on Wed Jan 27 09:41:43 2021
@Mail: daixuelei2014@163.com
@author:daixuelei
"""

import logging,os,sys
import click,re

logging.basicConfig(filename=os.path.basename(__file__).replace('.py','.log'),
                    format='%(asctime)s: %(name)s: %(levelname)s: %(message)s',level=logging.DEBUG,filemode='w')
logging.info(f"The command line is:\n\tpython3 {' '.join(sys.argv)}")

def LoadFasta(File):
    Dict = {}
    seq = ''
    for line in File:
        line = line.strip()
        if line[0] == '>':
            if len(seq) > 0:
                Dict[name] = seq
            name = line[1:]
            seq = ''
        else: seq += line
    Dict[name] = seq
    return Dict

@click.command()
@click.option('-r','--ref',type=click.File('r'),help='input the reference fasta file',required=True)
@click.option('-v','--vcf',type=click.File('r'),help='input the paftools vcf file',required=True)
@click.option('-o','--out',type=click.File('w'),help='output the changed format vcf file',required=True)
def main(ref,vcf,out):
    """
    Change the information for sniffles2
    """
    RefFaDict = LoadFasta(ref)
    for line in vcf:
        line = line.strip()
        if line.startswith('#'):
            out.write(f'{line}\n')
        elif 'IMPRECISE' in line:
            continue
        else:
            line = line.split('\t')
            Chrom,Start,ID,Ref,Alt = line[0],int(line[1])-1,line[2],line[3],line[4]
            Type = re.findall(r'SVTYPE=\w*',line[7])[0].split('=')[1]            
            if Type != 'BND':
                End = int(re.findall(r'END=\w*',line[7])[0].split('=')[1]) - 1
                Post_INFO = re.sub(r';END=\w+;', f';END={End};', '\t'.join(line[5:]))
            else:
                Post_INFO = '\t'.join(line[5:])
                
            if Type == 'DEL':
                RefSeq = RefFaDict[Chrom][(Start-1):End]
                AltSeq = RefFaDict[Chrom][Start-1]
                Svlen = -(len(RefSeq) - 1)
                Post_INFO = re.sub(r';SVLEN=\w+;', f';SVLEN={Svlen};', Post_INFO)
                out.write(f'{Chrom}\t{Start}\t{ID}\t{RefSeq}\t{AltSeq}\t{Post_INFO}\n')
            elif Type == 'INS':
                if Alt != '<INS>':
                    RefSeq = RefFaDict[Chrom][Start-1]
                    AltSeq = RefSeq + Alt
                    Svlen = len(Alt)
                    Post_INFO = re.sub(r';SVLEN=\w+;', f';SVLEN={Svlen};', Post_INFO)
                    out.write(f'{Chrom}\t{Start}\t{ID}\t{RefSeq}\t{AltSeq}\t{Post_INFO}\n')
            elif Type == 'BND':
                RefSeq = RefFaDict[Chrom][Start-1]
                AltSeq = Alt.replace('N', RefSeq)
                out.write(f'{Chrom}\t{Start}\t{ID}\t{RefSeq}\t{AltSeq}\t{Post_INFO}\n')
            else:
                RefSeq = RefFaDict[Chrom][Start-1]
                out.write(f'{Chrom}\t{Start}\t{ID}\t{RefSeq}\t{line[4]}\t{Post_INFO}\n')


if __name__ == '__main__':
    main()
