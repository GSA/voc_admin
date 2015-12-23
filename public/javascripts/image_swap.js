$(function() {
  deleteSwap();
  cloneSwap();
  runSwap();
})

function deleteSwap() {
  var img_src = "images/delete.png"
  var hover_src = "images/delete_hover.png"

  $(document).on("mouseover", ".deleteLink", function(e){
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', hover_src);
  });


  $(document).on("mouseout", ".deleteLink", function(e){
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', img_src);
  });
}

function cloneSwap(){
  var img_src = "images/clone.png"
  var hover_src = "images/clone_hover.png"

  $(document).on("mouseover", ".copyLink", function(e){
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', hover_src);
  });

  $(document).on("mouseout", ".copyLink", function(e) {
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', img_src);
  });
}

function runSwap() {
  var img_src = "images/run.png"
  var hover_src = "images/run_hover.png"
  $(document).on("mouseover", ".runLink", function(e) {
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', hover_src);
  });

  $(document).on("mouseout", ".runLink", function(e){
    var img_tag = $(this).children("img").first();
    img_tag.attr('src', img_src);
  });
}
