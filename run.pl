use strict;
use warnings;
use utf8;
use Encode qw(encode);
use feature qw(say);

=pod
USAGE: perl run.pl fukuoka.txt > result_fukuoka.csv
=cut

my $filename = 'zip_list.txt';
my $fh       = open_file($filename);

my %zip_list;
while ( my $line = <$fh> ) {
    chomp($line);
    my ( $zip, $address ) = split( /,/, $line );

    # 郵便番号下4桁が0は、ざっくりなので除く
    if ( $zip =~ /0{4}$/ ) {
        next;
    }

    $zip_list{$address} = $zip;
}

close($fh);

#use Data::Dumper;
#say Dumper %zip_list;

my %zip_address_tmp;
my @result;
$filename = $ARGV[0];
$fh       = open_file($filename);
while ( my $line = <$fh> ) {
    chomp($line);
    while ( my ( $address, $zip ) = each(%zip_list) ) {
        if ( $line =~ /$address/ ) {

            # 元の住所をハッシュに格納することで重複を削除
            $zip_address_tmp{$line} = $address . ',' . $zip;
        }
    }

    # 順番をキープしたいので、配列に格納する
    push @result, { 'base' => $line, 'value' => $zip_address_tmp{$line} };
}

close($fh);

foreach my $h (@result) {
    say encode( 'cp932', $h->{base} . ',' . $h->{value} );
}

# ファイルハンドルをオープンするサブルーチン
sub open_file {
    my $filename = shift;
    open my $fh, '<:utf8', $filename
      or die "Couldn't open $filename : $!";
    return $fh;
}
