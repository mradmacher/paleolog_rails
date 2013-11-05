ROOT_DIR="./public/system/images/images/000/000"
for dir in `ls $ROOT_DIR`
  do 
    for format in 'original' 'medium' 'thumb'
      do
        for file in `ls $ROOT_DIR/$dir/$format`
          do
            mv "$ROOT_DIR/$dir/$format/$file" "$ROOT_DIR/$dir/$format${file:${#file}-4}"
            rmdir "$ROOT_DIR/$dir/$format"
          done
      done
  done
