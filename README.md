pdf_info
==

Very simple wrapper to the [pdfinfo](http://linuxcommand.org/man_pages/pdfinfo1.html) unix tool, to provide the metadata information as a hash.

Usage
--

    require 'pdf/info'
    info = PDF::Info.new('/Users/tom/tmp/magazine.pdf')
    pp info.metadata

Gives you the following output:

    {:version=>1.3,
     :pages=>
      [[819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17],
       [819.213, 1077.17]],
     :page_count=>12,
     :encrypted=>false}
   
Each of the pages has an individual size in PDF points - that's just how PDFs are. If you want more of the metadata that `pdfinfo` outputs, send us a patch.

If you need to manually set the path to the `pdfinfo` binary:

    PDF::Info.command_path = "/usr/local/bin/pdfinfo"
