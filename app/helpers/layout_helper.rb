module LayoutHelper
  TITLE = 'Git Reports'
  DESCRIPTION = 'Git Reports is a free service that lets you set up a stable URL for anonymous users to submit bugs and other Issues to your GitHub repositories.'
  KEYWORDS = 'GitHub, git, issue, report, bug'

  def default_meta
    {
      description: DESCRIPTION,
      keywords: KEYWORDS,
      title: TITLE,
      icon: '/favicon.ico',
      og: {
        title: TITLE,
        url: request.url,
        site_name: TITLE,
        description: DESCRIPTION,
        image: 'https://gitreports.com/images/alarm.png',
        type: 'website'
      }
    }
  end

  def bootstrap_class_for(flash_type)
    case flash_type
    when :success
      'alert-success'
    when :error
      'alert-error'
    when :alert
      'alert-block'
    when :notice
      'alert-info'
    else
      flash_type.to_s
    end
  end
end
