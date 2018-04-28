;
; Copyright (c) 2017 Intel Corporation
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to
; deal in the Software without restriction, including without limitation the
; rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
; sell copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
; IN THE SOFTWARE.
;

(script-fu-register
	; Function Name
	"script-fu-extract_font_alpha"
	; Menu Path
	"<Toolbox>/Xtns/Script-Fu/Utils/extract_font_alpha"
	; Blurb
	"extract font alpha creates a c-source file with structures for the printable standard ASCII caharacters from 33d\('!'\) - 126d\('~'\)."
	; Author
	"Rod Frazer"
	; Copyright
	"2017, Intel Corporation"
	; Creation Date
	"2017/08/11"
	; Image Type
	""
	SF-FONT		"Font Name"		""
	SF-ADJUSTMENT	"Font Size"		'()
	SF-DIRNAME	"Output Directory"	""
)
(define (script-fu-extract_font_alpha FontName FontSize outDir)
	(let*
		(
			(c_font_name 0)
			(debug_str 0)
			(header_str 0)
			(message 0)
			(my_base_layer 0)
			(my_char_count 0)
			(my_height 0)
			(my_img 0)
			(my_str 0)
			(my_text_layer 0)
			(my_width 0)
			(my_x 0)
			(my_y 0)
			(outFile 0)
			(out_str 0)
			(outfile_stream 0)
			(rgb_mode 0)
			(struct_str 0)
			(temp_font_name 0)
			(this_alpha 0)
			(this_char_c_name 0)
			(this_char_extent_ascent 0)
			(this_char_extent_descent 0)
			(this_char_extent_height 0)
			(this_char_extent_width 0)
			(this_char_extents 0)
			(this_char_height 0)
			(this_char_width 0)
			(this_pixel 0)
			(this_pixel_array 0)
			(version_str 0)
		)

		(gimp-message-set-handler 1)
		(set! message (string-append "Begin processing font " FontName " " (number->string FontSize 10)))
		(gimp-message message)

		; define a version string
		(set! version_str "0.0.3")

		; set some constants
		(set! my_width 200)
		(set! my_height 200)
		(set! rgb_mode 0)

		; make a good C name from the font name and size
		(set! c_font_name "")
		(set! temp_font_name (list->string (map (lambda (next_char) (if (char-whitespace? next_char) #\_ next_char )) (map char-downcase (string->list FontName)))))
		(set! c_font_name (string-append temp_font_name "_" (number->string FontSize 10)))

		; open the c source output file
		(if (> (string-length outDir) 0)
			(set! outFile (string-append outDir "/" c_font_name ".c"))
			(set! outFile (string-append c_font_name ".c"))
		)
		(set! outfile_stream (open-output-file outFile))

		; output the header
		(set! header_str "/*\n")
		(set! header_str (string-append header_str "\n"))
		(set! header_str (string-append header_str "This output is generated by the GIMP script 'script-fu-extract_font_alpha'.\n"))
		(set! header_str (string-append header_str "The script instantiates each font glyph for the printable ASCII characters from\n"))
		(set! header_str (string-append header_str "33d\('!'\) through 126d\('~'\) and it extracts the alpha channel data for the glyph.\n"))
		(set! header_str (string-append header_str "\n"))
		(set! header_str (string-append header_str "Definition of font: " c_font_name "\n"))
		(set! header_str (string-append header_str "\n"))
		(set! header_str (string-append header_str "Script version: " version_str "\n"))
		(set! header_str (string-append header_str "\n"))
		(set! header_str (string-append header_str "Use the following code to import this font definition into your own source:\n"))
		(set! header_str (string-append header_str "\n"))
		(set! header_str (string-append header_str "struct abc_font_struct {\n"))
		(set! header_str (string-append header_str "\tunsigned long extents_width;\n"))
		(set! header_str (string-append header_str "\tunsigned long extents_height;\n"))
		(set! header_str (string-append header_str "\tunsigned long extents_ascent;\n"))
		(set! header_str (string-append header_str "\tunsigned long extents_descent;\n"))
		(set! header_str (string-append header_str "\tunsigned long bounds_width;\n"))
		(set! header_str (string-append header_str "\tunsigned long bounds_height;\n"))
		(set! header_str (string-append header_str "\tunsigned char *char_alpha_map;\n"))
		(set! header_str (string-append header_str "\tunsigned long reserved;\n"))
		(set! header_str (string-append header_str "};\n"))
		(set! header_str (string-append header_str "\n"))
		(set! header_str (string-append header_str "extern struct abc_font_struct " c_font_name "\[\];\n"))
		(set! header_str (string-append header_str "\n"))
		(set! header_str (string-append header_str "*/\n"))
		(display header_str outfile_stream)

		; begin the structure string
		(set! struct_str "")
		(set! struct_str (string-append struct_str "struct abc_font_struct {\n"))
		(set! struct_str (string-append struct_str "\tunsigned long extents_width;\n"))
		(set! struct_str (string-append struct_str "\tunsigned long extents_height;\n"))
		(set! struct_str (string-append struct_str "\tunsigned long extents_ascent;\n"))
		(set! struct_str (string-append struct_str "\tunsigned long extents_descent;\n"))
		(set! struct_str (string-append struct_str "\tunsigned long bounds_width;\n"))
		(set! struct_str (string-append struct_str "\tunsigned long bounds_height;\n"))
		(set! struct_str (string-append struct_str "\tunsigned char *char_alpha_map;\n"))
		(set! struct_str (string-append struct_str "\tunsigned long reserved;\n"))
		(set! struct_str (string-append struct_str "} " c_font_name "[94] = {\n"))

		; create a base image
			;(gimp-image-new width height type)
		(set! my_img (car(gimp-image-new my_width my_height rgb_mode)))

		; create a new base layer with alpha
			;(gimp-layer-new image width height type name opacity mode)
		(set! my_base_layer (car (gimp-layer-new my_img my_width my_height 0 "base_layer" 100 0)))
			;(gimp-image-add-layer image layer position)
		(gimp-image-add-layer my_img my_base_layer -1)
			;(gimp-layer-add-alpha layer)
		(gimp-layer-add-alpha my_base_layer)
			;(gimp-drawable-fill drawable fill_type)
		(gimp-drawable-fill my_base_layer 3)

		; define some variables for use throughout the script
		(set! my_str (make-string 1 #\space))

		; loop thru all printable ASCII characters
		(set! my_char_count 33)
		(while (< my_char_count 127)

			(string-set! my_str 0 (integer->char my_char_count))

			; draw the next character
				;gimp-text-fontname image drawable x y text border antialias size size_type fontname)
			(set! my_text_layer (car (gimp-text-fontname my_img my_base_layer 0 0 my_str 0 1 FontSize 0 FontName)))

			; get it's actual bounds
				;(gimp-drawable-width drawable)
			(set! this_char_width (car (gimp-drawable-width my_text_layer)))

				;(gimp-drawable-height drawable)
			(set! this_char_height (car (gimp-drawable-height my_text_layer)))

			; get it's extents
				;gimp-text-get-extents-fontname text size size_type fontname)
			(set! this_char_extents (gimp-text-get-extents-fontname my_str FontSize 0 FontName))

			(set! this_char_extent_width (car this_char_extents))
			(set! this_char_extent_height (cadr this_char_extents))
			(set! this_char_extent_ascent (caddr this_char_extents))
			(set! this_char_extent_descent (car (cdddr this_char_extents)))

			; get the alpha values

			(set! this_char_c_name (string-append c_font_name "_" (number->string (char->integer (string-ref my_str 0)) 10)))
			(set! out_str (string-append  "static unsigned char " this_char_c_name "[" (number->string (* this_char_width this_char_height) 10) "] = {\n"))
			(display out_str outfile_stream)

			(set! my_y 0)
			(while (< my_y this_char_height)

				(set! my_x 0)
				(set! out_str "")
				(while (< my_x this_char_width)

						;(gimp-drawable-get-pixel drawable x_coord y_coord)
					(set! this_pixel (gimp-drawable-get-pixel my_text_layer my_x my_y))
					(set! this_pixel_array (cadr this_pixel))
					(set! this_alpha (vector-ref this_pixel_array 3))

					(set! out_str (string-append out_str " "))
					(if (< this_alpha 10)
						(set! out_str (string-append out_str "  " (number->string this_alpha) ","))
						(if (< this_alpha 100)
							(set! out_str (string-append out_str " " (number->string this_alpha) ","))
							(set! out_str (string-append out_str "" (number->string this_alpha) ","))
						)
					)

					(set! my_x (+ my_x 1))

				)

				(set! out_str (string-append out_str "\n"))
				(display out_str outfile_stream)

				(set! my_y (+ my_y 1))

			)
			(display "};\n\n" outfile_stream)

			; write the simple stuff to the temporary string
			(set! struct_str (string-append struct_str  "  { "))
			(set! struct_str (string-append struct_str (number->string this_char_extent_width 10) ", "))
			(set! struct_str (string-append struct_str (number->string this_char_extent_height 10) ", "))
			(set! struct_str (string-append struct_str (number->string this_char_extent_ascent 10) ", "))
			(set! struct_str (string-append struct_str (number->string this_char_extent_descent 10) ", "))
			(set! struct_str (string-append struct_str (number->string this_char_width 10) ", "))
			(set! struct_str (string-append struct_str (number->string this_char_height 10) ", "))
			(set! struct_str (string-append struct_str this_char_c_name ", "))
			(set! struct_str (string-append struct_str  "0, },\n"))

			; remove the character layer from the image
				;(gimp-floating-sel-remove floating_sel)
			(gimp-floating-sel-remove my_text_layer)

			; bottom of loop
			(set! my_char_count (+ my_char_count 1))
		)
		; close out the structure string
		(set! struct_str (string-append struct_str "};\n\n"))
		(display struct_str outfile_stream)

		; close the c source file
		(close-output-port outfile_stream)

		; Delete the image
		(gimp-image-delete my_img)

		(set! message (string-append "Complete processing font " FontName " " (number->string FontSize 10)))
		(gimp-message message)
	)
)

