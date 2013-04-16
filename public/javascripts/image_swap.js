$(function() {

  deleteSwap();

  cloneSwap();

  runSwap();

})

function deleteSwap() {
  var img_src = "images/delete.png"
  var hover_src = "images/delete_hover.png"

  $(".deleteLink").live("mouseover", function(){
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', hover_src);
  });

  $(".deleteLink").live("mouseout", function() {
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', img_src);
  });
}

function cloneSwap(){
  var img_src = "images/clone.png"
  var hover_src = "images/clone_hover.png"

  $(".copyLink").live("mouseover", function(){
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', hover_src);
  });

  $(".copyLink").live("mouseout", function() {
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', img_src);
  });
}

function runSwap() {
  var img_src = "images/run.png"
  var hover_src = "images/run_hover.png"
// alert(hover_src);
  $(".runLink").live("mouseover", function(){
    // alert(window.location.host + "/" );
    var img_tag = $(this).children("img").first();

    //img_tag('run_hover.png')
     img_tag.attr('src', hover_src);
  });

  $(".runLink").live("mouseout", function() {
    var img_tag = $(this).children("img").first();
    //img_tag('run.png')
    img_tag.attr('src', img_src);
  });
}