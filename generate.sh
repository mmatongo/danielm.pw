#! /usr/bin/env bash


title_wrapper() {
    # remove extension
    # snake to title case
    echo "$1" | sed -E -e "s/\..+$//g"  -e "s/_(.)/ \\1/g" -e "s/^(.)/\\1/g"
}

read_time() {
    minu="$(eva -f 1 $1/150 | xargs)"
    echo "$minu"
}

height() {
    cm="$(eva -f 2 $1*18*0.0222 | xargs)"
    echo "$cm"
}

link_wrapper() {
    # 1 - id
    # 2 - title
    # 3 - date
    # 4 - read time
    echo -ne "
    <tr>
        <td class="table-post">
            <div class=\"date\">
                $3
            </div>
            <a href=\"/posts/$1\" class=\"post-link\">
                <span class=\"post-link\">$2</span>
            </a>
        </td>
        <td class="table-stats">
            <span class=\"stats-number\">
                $4
            </span>
            <span class="stats-unit">min</span>
        </td>
    </tr>
    "
}

intro() {
    echo -ne "
    <div class="intro">
        Hi. 
        <div class="hot-links">
            <a href="https://danielm.pw/index.xml" class="feed-button">Subscribe</a>
            <a href="https://liberapay.com/mmatongo/donate" class="donate-button">Donate</a>
        </div>
        <p>My names are Daniel M. Matongo.</p>
        <p>
        I am a compsci undergrad, programmer and amateur writer.
        I contribute to open-source projects to pass time and I also write.
        </p>
        <p>Send me a mail at me@danielm.pw.</p>
    </div>
    "
}

cat > ./docs/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<link rel="stylesheet" href="./style.css">
<link rel="alternate" type="application/atom+xml" title="daniel's musings" href="./index.xml">
<meta charset="UTF-8">
<meta name="viewport" content="initial-scale=1">
<meta content="#ffffff" name="theme-color">
<meta name="HandheldFriendly" content="true">
<meta property="og:title" content="danielm">
<meta property="og:type" content="website">
<meta property="og:description" content="daniel's musings">
<meta property="og:url" content="https://danielm.pw">
<link rel="icon" type="image/x-icon" href="/favicon.png">
<title>danielm.pw</title>
<body>
    <h1 class="heading">.</h1>
    <h4 class="subheading">daniel's musings</h4>
    <div class="posts">
    <div class="post">
EOF

echo -ne "$(intro)<table>" >> ./docs/index.html

# posts
posts=$(ls -t ./posts)
mkdir -p docs/posts
rm -rf "./docs/posts/"

for f in $posts; do
    file="./posts/"$f
    id="${file##*/}"    # ill name my posts just fine

    # generate posts
    stats=$(wc "$file")
    words="$(echo $stats | awk '{print $2}')"
    lines="$(echo $stats | awk '{print $1}')"

    r_time="$(read_time $words)"
    height="$(height $lines)"

    post_title=$(title_wrapper "$id")
    echo "[~] $post_title"
    post_date=$(date -r "$file" "+%d/%m — %Y")
    post_link=$(link_wrapper "${id%.*}" "$post_title" "$post_date" "$r_time" "$height")
    echo -ne "$post_link" >> docs/index.html

    id="${id%.*}"
    mkdir -p "docs/posts/$id"
    esh -s /bin/bash \
        -o "docs/posts/$id/index.html" \
        "./post.esh" \
        file="$file" \
        date="$post_date" \
        title="$post_title" \
        read_time="$r_time" \
        height="$height" \
        intro="$intro"
done

# generate rss feeds
echo "generating RSS feeds ..."
esh -s /bin/bash \
    -o "./docs/index.xml" \
    "rss.esh"

cat >> ./docs/index.html << EOF
    </table>
    <div class="separator"></div>
    <div class="footer">
        <a href="https://github.com/mmatongo">github</a> · 
        <a href="mailto:me@danielm.pw">Mail</a> ·
        <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/">
            <img class="footimgs" src="https://d33wubrfki0l68.cloudfront.net/94387e9d77fbc8b4360db81e72603ecba3df94a7/632bc/static/cc.svg">
        </a>
    </div>
    </div>
</div>
</body>
</html>
EOF
