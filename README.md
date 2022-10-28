# sdMAF

sdMAF is a R based commend-line tool used to compute sex differences in allele frequencies. 

sdMAF is free and comes with ABSOLUTELY NO WARRANTY. 

Details of the method can be found [here](https://journals.plos.org/plosgenetics/article/authors?id=10.1371/journal.pgen.1010231). 

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

    PROGRAM [-h] -f <filename>  -m <filename>  [--version]
                 [--bim <filename>] [-o <filename>] [--multi-allelic]
                 [--mac <minimum count>]

## Required Arguments 
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
    --multi-allelic       Indicate whether to keep multi-allelic SNPs in the
                          results or not. Default FALSE.
    --mac <minimum count>
                          Minimum allele count filter. Default 5.

## Examples

    Rscript sdMAF.R \
            -f /female/pilot.txt \
            -m /male/pilot.txt \
            --mac 10 \
            -o pilot_test
            
    Checking if inputs are valid.
    Autosomal/NPR region detected based on male genotype count file.
    No bim file provided. OK unless ID column from genotype file not all in chr:bp:A1:A2 form.
    Input checkers all passed, now applying filters.
    Keeping 487 biallelic SNPs out of 499 total SNPs from Input.
    Keeping 184 SNPs out of 487 SNPs based on a minor allele count filter of 10.
    All filters applied, now computing sdMAF!
    Now calculated 10% (19/184).
    Now calculated 20% (37/184).
    Now calculated 30% (56/184).
    Now calculated 40% (74/184).
    Now calculated 50% (92/184).
    Now calculated 60% (111/184).
    Now calculated 70% (129/184).
    Now calculated 80% (148/184).
    Now calculated 90% (166/184).
    Finito !
    Writing results to pilot_test.sdMAF

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
