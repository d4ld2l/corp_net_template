class Hash
  def strip_blanks
    final_hash =
        self.transform_values do |v|
          if v.blank?
            nil
          elsif v.kind_of?(Array)
            stripped_array = v.delete_if(&:blank?)
            if stripped_array.any?
              stripped_array
            else
              nil
            end
          elsif v.kind_of?(Hash)
            v.strip_blanks
          else
            v
          end
        end
    final_hash.to_h.compact
  end
end

class String
  def strip_html_tags
    ActionView::Base.full_sanitizer.sanitize(self)
  end
end
