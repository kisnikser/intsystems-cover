$pdf_mode = 5;
$xelatex = 'xelatex -interaction=nonstopmode -synctex=1 %O %S';

push @generated_exts, 'png', 'zip';

# Overleaf jobname is output.pdf. ImageMagick PDF policy often
# blocks convert; Ghostscript is what actually runs there.
END {
  my $pdf = -e 'output.pdf' ? 'output.pdf' : 'main.pdf';
  open my $log, '>', 'png-export.log';
  if (!-e $pdf) {
    print $log "no pdf ($pdf)\n";
    close $log;
  }
  else {
    print $log "pdf $pdf\n";
    my $gs = system(
      'gs', '-dBATCH', '-dNOPAUSE', '-dQUIET',
      '-sDEVICE=png16m', '-g1920x1080', '-dPDFFitPage', '-dUseCropBox',
      '-sOutputFile=cover-%d.png', $pdf
    );
    print $log "gs $gs\n";
    if ($gs != 0) {
      my $im = system(
        'convert', '-density', '300', '-resize', '1920x1080',
        '-background', 'white', '-alpha', 'remove', '-alpha', 'off',
        '-scene', '1', $pdf, 'cover.png'
      );
      print $log "convert $im\n";
    }
    my @png = sort glob('cover-*.png');
    print $log 'png ' . scalar(@png) . "\n";
    print $log "$_\n" for @png;
    if (@png) {
      # Overleaf Other logs hides .png/.zip; .log is in the download list.
      my $zip = system('zip', '-j', 'covers-png.log', @png);
      print $log "zip $zip covers-png.log (rename to .zip)\n";
    }
    close $log;
  }
}
