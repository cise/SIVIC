module SpacesHelper
  
  def link_capitals(capitals, capital_sel = nil)
    links = link_to_unless capital_sel==nil, t("space.all"), "spaces?id_space=all"
    for capital in capitals
      links += " - "      
      links += link_to_unless capital_sel == capital['capital'], capital['capital'], 
                 "spaces?id_space=all&cap=" + capital['capital']
    end
    links
  end
  
  
  
    def max_word_length text
    first_pos = 0
    max_length = 0
    while !((pos = (text+" ").index(' ', first_pos)).nil?)
      if (pos - first_pos) > max_length
        max_length = pos - first_pos
      end
      first_pos = pos + 1
    end
    return max_length
  end
  
  def create_auto_logo text, logo_style,spaceId
    
    # We establish the paths for the pre-defined images, and the temporal dir for the generated logo
    images_path = File.join(RAILS_ROOT, "public", "images")
    tmp_path = File.join(images_path, "tmp")
    background_generic = File.join(images_path, "vcc-logo-bg.png")
    background_generated = File.join(tmp_path, "vcc-logo-"+spaceId.to_s + ".png")
    
    # We open, read-only, the generic background image
    f = File.open(background_generic, "r+")
    img = Magick::Image.read(f).first
    
    # This will be the blank image which will contain the text
    logo_text = Magick::Image.new(img.columns, img.rows)
    # To create the text, we use a new "Draw" object, and set some basic styles
    gc = Magick::Draw.new
    gc.font_family = "Helvetica"
    gc.font_style = Magick::ObliqueStyle
    gc.font_weight = Magick::LighterWeight
    gc.gravity = Magick::CenterGravity
    gc.stroke = "darkblue"
    gc.stroke_opacity(1)
    gc.text_antialias(true)
    gc.stroke_antialias(true)
    gc.stroke_linecap("round")
    gc.fill = "darkblue"

    # Depending on the desired logo_style, we create a text or another 
    case logo_style
      when 1
        gc.pointsize = 1.7 * img.columns / text.length
        gc.gravity = Magick::SouthGravity
        gc.annotate(logo_text,img.columns,img.rows,0,0,text+"\n")
        auto_logo = img.composite!(logo_text, Magick::CenterGravity, Magick::ColorBurnCompositeOp)
      when 2
        gc.pointsize = 1.7 * img.columns / text.length
        gc.annotate(logo_text,img.columns,img.rows,0,0,text)
        logo_text = logo_text.shade(true, 300, 30)
        auto_logo = img.composite!(logo_text, Magick::CenterGravity, Magick::HardLightCompositeOp)
      when 3
        gc.pointsize = 1.5 * img.columns / (max_word_length text)
        text = text.gsub(" ", "\\n")
        gc.annotate(logo_text,0,0,0,0,text)
        auto_logo = img.composite!(logo_text, Magick::CenterGravity, Magick::ColorBurnCompositeOp)
      when 4
        gc.pointsize = 1.5 * img.columns / (max_word_length text)
        text = text.gsub(" ", "\\n")
        gc.annotate(logo_text,img.columns,img.rows,0,0,text)
        logo_text = logo_text.shade(true, 300, 70)
        auto_logo = logo_text
      when 5
        gc.pointsize = 1.5 * img.columns / (max_word_length text)
        text = text.gsub(" ", "\\n")
        gc.annotate(logo_text,img.columns,img.rows,0,0,text)
        logo_text = logo_text.shade(false, 300, 30)
        blank_bg = Magick::Image.new(img.columns, img.rows, GradientFill.new(0, 0, img.columns, 0, '#EBEBEB', '#BDD8EB'))
        auto_logo = blank_bg.composite!(logo_text, Magick::CenterGravity, Magick::HardLightCompositeOp)
    end
    f.close
    
    # Finally, we store the new image in the temp path
    auto_logo.write("png:" + background_generated)
  end
  
  
  
end
