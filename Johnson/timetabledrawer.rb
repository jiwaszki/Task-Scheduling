require 'rmagick'

module TimetableDrawer
  # draw timetable
  def self.draw_timetable(timetable, table_end, name_of_file, fixed_size = 100)
    imgl = Magick::ImageList.new
    imgl.new_image((table_end) * fixed_size + fixed_size / 2,
                   (timetable.length + 0.1) * fixed_size + fixed_size / 2,
                   Magick::HatchFill.new('white','lightcyan2'))

    (0...timetable.length).each do |i|
      if i == 0
        f_y = 0
        s_y = 0
      else
        f_y = i * (fixed_size + 1)
        s_y = i * fixed_size
      end
      (0...table_end).each do |j|
        if j == 0
          f_x = 0
          s_x = 0
        else
          f_x = j * (fixed_size + 1)
          s_x = j * fixed_size
        end

        square = Magick::Draw.new

        if timetable[i][j] == 0 || timetable[i][j] == nil
          square.fill_opacity(20)
          square.stroke_width(fixed_size / 20)
          square.stroke('#292925')
          square.fill('#56574F')
          square.rectangle(s_x, s_y, s_x + fixed_size, s_y + fixed_size)
          square.draw(imgl)
        else
          square.fill_opacity(100)
          square.stroke_width(fixed_size / 20)
          square.stroke('#292925')
          square.fill('#BBBDAC')
          square.rectangle(s_x, s_y, s_x + fixed_size, s_y + fixed_size)
          square.draw(imgl)

          txt = Magick::Draw.new

          txt.font_weight(Magick::NormalWeight)
          txt.font_style(Magick::NormalStyle)
          txt.pointsize(fixed_size / 3)
          txt.fill('#1F1F57')
          txt.stroke('transparent')
          txt.text(s_x + fixed_size / 8, s_y + fixed_size / 2, "Z" + timetable[i][j].to_s)

          txt.draw(imgl)
        end
      end
    end

    # draw timeline
    t_x = table_end * fixed_size
    t_y = (timetable.length + 0.5) * fixed_size - fixed_size / 2

    timeline = Magick::Draw.new

    timeline.fill('#292925')
    timeline.stroke('#292925').stroke_width(fixed_size / 10)
    timeline.line(0, t_y, t_x, t_y)
    # make dots
    (0..table_end).each do |k|
      timeline.circle(k * fixed_size, t_y,
                      k * fixed_size + 2, t_y + fixed_size / 10)
      # label the dot
      dot = Magick::Draw.new

      dot.font_weight(Magick::NormalWeight)
      dot.font_style(Magick::NormalStyle)
      dot.pointsize(fixed_size / 3)
      dot.fill('#292925')
      dot.stroke('transparent')
      dot.text(k * fixed_size, t_y + fixed_size / 2, k.to_s)

      dot.draw(imgl)
    end
    timeline.draw(imgl)

    imgl.border!(5,5, '#292925')
    imgl.write(name_of_file + ".gif")
  end
end
