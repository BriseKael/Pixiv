#!/usr/bin/perl

# print "hello \n";

`mkdir temp`;

# position is in Chrome -> cookie
# used for login
$cookie = "PHPSESSID=21545843_640c69fbe2f5e96f54ba30710eaf544d"; # not used

$useragent = "Mozilla/5.0 (Windows; U; Windows NT 5.2) AppleWebKit/525.13 (KHTML, like Gecko) Chrome/0.2.149.27 Safari/525.13";

$referer = "http://www.pixiv.net/"; # not used

# url for 1~50
$daily_url = "www.pixiv.net/ranking.php?mode=daily";

# url for 51~100
# $daily_url = "www.pixiv.net/ranking.php?mode=daily&p=2";

# get date, format is 20170112
$dir_name = `date +%Y%m%d`;

# if given exact date
if (@ARGV == 1)
{
	$daily_url = "www.pixiv.net/ranking.php?mode=daily&date=$ARGV[0]";
	$dir_name = $ARGV[0];
}

$document = `curl --user-agent "$useragent" --referer "$referer" -s "$daily_url"`;

# <script>pixiv.context.mode = "daily"
($section) = $document =~ "(<script>pixiv\.context\.mode \= \"daily\".*)";

%picture; # not used
@suffixes = ('.jpg', '.png', '.gif', '.bmp');

# <section id="9" class="ranking-item" data-rank="9" data-rank-text="#9" data-title="無題" data-user-name="♣3" 
# data-date="2017年01月18日 00:06" data-view-count="23271" data-total-score="9556" data-attr="" data-id="60987736">

while ($section =~ s/<section id=\"([0-9]+)\".*?data\-id=\"([0-9]+)\"(.*?)<\/section>//)
{

# http://i2.pixiv.net/c/240x480/img-master/img/2017/01/18/00/00/01/60987445_p0_master1200.jpg
#_illust_modal ui-modal-close-box
# http://i2.pixiv.net/img-original/img/2017/01/18/00/00/01/60987445_p0.jpg

# http://www.pixiv.net/member_illust.php?mode=medium&illust_id=61004016
	$index = $1;
	$illust_id = $2;
	$tail = $3;

	print "$index: $illust_id: ";
	# print "$tail\n";

	$referer_temp = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=${illust_id}";

	# medium
	($layout_url) = $tail =~ ".*<div class=\"_layout\-thumbnail\".*?data\-src=\"(.*?)\".*";
	# print "$layout_url\n";

	# `curl -s -O ${layout_url}`;

	($inumber) = $layout_url =~ m/^.*\/\/(i[0-9]+)\.pixiv.*$/;
	($time) = $layout_url =~ m/^.*?([0-9\/]+\_p[0-9]+).*$/;

	foreach $suffix (@suffixes)
	{
		$picture_url = "http://${inumber}.pixiv.net/img-original/img${time}${suffix}";

		# print "$picture_url\n";

		`curl --user-agent "$useragent" --referer "$referer_temp" -s -O "${picture_url}"`;

		$p_number = 0;

		$file_name = "${illust_id}_p${p_number}${suffix}";
		($file_size) = `du $file_name` =~ m/([0-9]+).*/;


		if ($file_size > 10)
		{
			`mv $file_name $index\_$file_name`;
			`mv $index\_$file_name temp`;

			print "$picture_url\n";

			#manga
			while (true)
			{
				$p_number += 1;
				$file_name_manga = "${illust_id}_p${p_number}${suffix}";

				$picture_url_manga = $picture_url;
				$picture_url_manga =~ s/(.*)$file_name/$1${file_name_manga}/;

				`curl --user-agent "$useragent" --referer "$referer_temp" -s -O "${picture_url_manga}"`;
				($file_size_manga) = `du $file_name_manga` =~ m/([0-9]+).*/;

				if ($file_size_manga > 10)
				{
					`mv $file_name_manga $index\_$file_name_manga`;
					`mv $index\_$file_name_manga temp`;

					print "$picture_url_manga\n";
				}
				else
				{
					`rm $file_name_manga`;
					last;
				}

			}
			last;
		}
		else
		{
			`rm $file_name`;
		}

	}

	# ($suffix) = $layout_url =~ m/^.*\.([a-z]+)$/;
	# print "$time\n";
}

`mv temp $dir_name`;


# `mv *.jpg temp`;

# print "$section\n";

# du 
# curl --referer "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=60990776" -s -O http://i1.pixiv.net/img-original/img/2017/01/18/04/17/58/60990776_p0.jpg


















