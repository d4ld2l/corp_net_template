module FlashNoticesHelper

  def flash_notice_class(notice_type)
    case notice_type
      when 'alert'
        "alert alert-danger"
      else
        "alert alert-info"
    end
  end

end
