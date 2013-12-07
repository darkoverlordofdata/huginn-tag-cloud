#+--------------------------------------------------------------------+
#| tag_cloud.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Huginn
#|
#| Huginn is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# tag cloud huginn-plugin
#
fs = require('fs')
path = require('path')

module.exports = (Liquid, site) ->


  #
  # build the tag content
  #
  $tag_page = site.tag_page_layout
  $tag_dir = site.tag_page_dir
  $tags = {}
  $total = 0

  for $post in site.posts
    if $post.tag isnt ''
      $tag = $post.tag
      $tags[$tag]=[] unless $tags[$tag]?
      $tags[$tag].push $post

      $total++
    if $post.tags isnt ''
      for $tag in $post.tags.split(' ')
        $tags[$tag]=[] unless $tags[$tag]?
        $tags[$tag].push $post

  for $tag, $posts of $tags
    $total += $posts.length

  # find the biggest tag
  $max = 0
  $min = 0
  for $tag, $posts of $tags
    $max = Math.max($max, $posts.length)
    $min = Math.min($min, $posts.length)

  #
  # Generate the html for the site
  #
  $html = ''
  $mult = (5-1)/($max-$min)
  for $tag, $posts of $tags
    $size = Math.floor(1 + (($max-($max-($posts.length-$min)))*$mult))
    $html += "<a href=\"/#{$tag_dir}/#{$tag}\" class=\"set-#{$size}\">#{$tag}</a> "

  site.tag_cloud = $html

  #
  # Generate a landing page for each tag
  #


  fs.mkdirSync "#{site.destination}/#{$tag_dir}" unless fs.existsSync("#{site.destination}/#{$tag_dir}")
  $tmp = "#{site.source}/_layouts/#{$tag_page}.html"
  $dir = "#{site.destination}/#{$tag_dir}"

  for $tag, $posts of $tags
    $out = "#{$dir}/#{$tag}"
    fs.mkdirSync $out unless fs.existsSync($out)
    fs.writeFileSync "#{$out}/index.html", $build.render($tmp, posts: $posts)


  Liquid.Template.register_filter
    tags: ($site) ->
      $site.tag_cloud