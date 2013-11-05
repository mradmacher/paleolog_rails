toggle_images = function( obj, image1, image2 ) {
  if( obj.width == 350 ) {
    obj.src = image1;
    obj.width = obj.oldsize;
  } else { 
    obj.src = image2;
    obj.oldsize = obj.width;
    obj.width = 350;
  }
}
