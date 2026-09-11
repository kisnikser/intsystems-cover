$pdf_mode = 5;
$xelatex = 'xelatex -interaction=nonstopmode -synctex=1 %O %S';

# Overleaf writes output.pdf; local latexmk writes main.pdf.
END {
  my $pdf = -e 'output.pdf' ? 'output.pdf' : 'main.pdf';
  return unless -e $pdf;
  system('pdftoppm', '-png', '-scale-to-x', '1920', '-scale-to-y', '1080', $pdf, 'cover');
  my @png = glob('cover-*.png');
  system('zip', '-j', 'covers-png.zip', @png) if @png;
}
