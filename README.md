# sdMAF 0.0.3 Manual

sdMAF 0.0.3 is a R based commend-line tool used to compute sex differences in allele frequencies. 

sdMAF is free and comes with ABSOLUTELY NO WARRANTY. 

Details of the method can be found [here](https://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.1010231#sec017:~:text=MAF%20between%20populations.-,1.1.%20sdMAF%20test.,-For%20each%20bi). 

Copyright 2022 Zeya Chen, Zhong Wang, Delnaz Roshandel, Lei Sun, Andrew D. Paterson. 

Report bugs to zeya [dot] chen [at] sickkids [dot] ca.

<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- USAGE EXAMPLES -->
## Usage

    usage: sdMAF -f <filename>  -m <filename>  [-h] [--version]
             [--bim <filename>] [-o <filename>] [-l <filename>]
             [--multi-allelic] [--sex-specific] [--mac <minimum count>]

## Required Arguments 
Only [gcount](https://www.cog-genomics.org/plink/2.0/formats#gcount:~:text=FST%20estimate-,.gcount,-(genotype%20count%20report)) files required.

    -f <filename>, --female <filename>
                          Female genotype count file produced by PLINK.
    -m <filename>, --male <filename>
                          Male genotype count file produced by PLINK.
## Optional Arguments
    
    -h, --help            show this help message and exit
    --version             Print the version of this tool and exit.
    --bim <filename>      Input bim file address to extract base pair
                          position.Optional if ID in .gcount file are all
                          chr:bp:a1:a2.
    -o <filename>, --out <filename>
                          Specify output file name and address. Default
                          autosomal.sdMAF.
    -l <filename>, --log <filename>
                          Log file name and address. Default 'YOURINPUTin--
                          out'_sdMAF.log.
    --multi-allelic       Indicate whether to keep multi-allelic SNPs in the
                          results or not. Default FALSE.
    --sex-specific        Include to use sex specific minimum allele count
                          filter for both males and females.
    --mac <minimum count>
                          Sex combined minimum allele count filter. Variant with
                          minor allele count less than input will be filtered
                          out. Default 5.

## Quick Start-Up Guide

We will batch run entire genome.
    
    ####Make your own Analysis.sh file by filling in these address.

    #PBS -l vmem=30g,mem=30g
    #PBS -l walltime=24:00:00

    #PBS -o /YourOutFolder
    #PBS -e /YourErrorFolder

    cd /YourWorkDirectory

    chr=$PARAM1
    
    module load plink2
    
    plink2 --bfile /YourBedFileFolder/BedFileNamechr${chr} --geno-counts --keep-males --out /YourMaleGcountFolder/chr${chr}
    plink2 --bfile /YourBedFileFolder/BedFileNamechr${chr} --geno-counts --keep-females --out /YourFemaleGcountFolder/chr${chr}

    module load R

    Rscript sdMAF.R \
    -f /YourMaleGcountFolder/chr${chr} \
    -m /YourMaleGcountFolder/chr${chr} \
    --mac 10 \
    -o /YourOutFolder/OutFileNamechr${chr} \
    -l /YourLogFolder/LogFileNamechr${chr}
    
    #### on HPF

    #Autosomes
    cd /WhereAnalysis.shLocated
    
    let a=1
    while [ $a -le 22 ]
    do
        qsub  -v PARAM1=$a Analysis.sh             
        let a=$a+1
    done
    
    #Caution! Check naming of PAR/NPR regions in your Bed files before using this.
    qsub  -v PARAM1=X Analysis.sh
    qsub  -v PARAM1=XY Analysis.sh

    #Merging Results After All Batch Jobs Completed.
    let a=1
    head -n 1 /YourOutFolder/OutFileNamechr${a}.sdMAF > header.txt
    while [ $a -le 22 ]
       do
            echo "$(tail -n +2 /YourOutFolder/OutFileNamechr${a}.sdMAF)" > /YourOutFolder/OutFileNamechr${a}.sdMAF      
        let a=$a+1
    done
    echo "$(tail -n +2 /YourOutFolder/OutFileNamechrX.sdMAF)" > /YourOutFolder/OutFileNamechrX.sdMAF
    echo "$(tail -n +2 /YourOutFolder/OutFileNamechrXY.sdMAF)" > /YourOutFolder/OutFileNamechrXY.sdMAF
    cat header.txt /YourOutFolder/OutFileNamechr* > /YourOutFolder/OutFileName_chr1to23sdMAF.txt
    
    
## Example 

    #Use plink to produce gcount files.
    plink2 --bfile pilot --geno-counts --keep-males --out /male/pilot
    plink2 --bfile pilot --geno-counts --keep-females --out /female/pilot
    
    #Run sdMAF.
    Rscript sdMAF.R \
            -f /female/pilot.gcount \
            -m /male/pilot.gcount \
            --mac 10 \
            -o /out/pilot_test \
            -l /log/pilot_test
            
    ########## sdMAF 0.0.3 ########## 
    An R based commend-line tool used to compute sex differences in allele frequencies.
    sdMAF is free and comes with ABSOLUTELY NO WARRANTY.
    Details of the method can be found at: 
    https://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.1010231#sec017:~:text=MAF%20between%20populations.-,1.1.%20sdMAF%20test.,-For%20each%20bi  
    Copyright 2022 Zeya Chen, Zhong Wang, Delnaz Roshandel, Lei Sun, Andrew D. Paterson. 
    Report bugs to zeya [dot] chen [at] sickkids [dot] ca.
    #################################
    Checking if inputs are valid.
    Loading female gcount file found from /female/pilot.txt.
    198380 samples detected from female gcount file.
    Number of SNPs by chromosome from female gcount file:
          X 
    3917799 
    Loading male genotype count file found from /male/pilot.txt.
    165243 samples detected from male gcount file.
    Number of SNPs per chromosome from male gcount file:
          X 
    3917799 
    3917799 chrX NPR SNPs detected.
    0 autosomal/PAR SNPs detected.
    0 missing SNPs detected. Don't worry it will be filtered out later.
    No bim file provided. OK unless ID column from genotype file not all in CHR:BP:A1:A2 form.
    ################################# 
    Input checkers all passed, now applying filters.
    Keeping 115459 biallelic SNPs out of 3917799 total SNPs from Input.
    Keeping 63289 SNPs out of 115459 SNPs based on a sex combined minor allele count filter of 10.
    ################################# 
    All filters applied, now computing sdMAF!
    Now calculated 5% (3165/63289).
    Now calculated 10% (6329/63289).
    Now calculated 15% (9494/63289).
    Now calculated 20% (12658/63289).
    Now calculated 25% (15823/63289).
    Now calculated 30% (18987/63289).
    Now calculated 35% (22152/63289).
    Now calculated 40% (25316/63289).
    Now calculated 45% (28481/63289).
    Now calculated 50% (31645/63289).
    Now calculated 55% (34809/63289).
    Now calculated 60% (37974/63289).
    Now calculated 65% (41138/63289).
    Now calculated 70% (44303/63289).
    Now calculated 75% (47467/63289).
    Now calculated 80% (50632/63289).
    Now calculated 85% (53796/63289).
    Now calculated 90% (56961/63289).
    Now calculated 95% (60125/63289).
    Finito !
    63289 total SNPs in results.
    63289 were chrX NPR SNPs.
    0 were autosomal/PAR SNPs.
    Number of SNPs by chromosome table:

        X 
    63289 
    Writing results to /out/pilot_test.sdMAF and logs to /log/pilot_test_sdMAF.log

    
    

<p align="right">(<a href="#readme-top">back to top</a>)</p>




<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
