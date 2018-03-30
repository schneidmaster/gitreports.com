module LayoutHelper
  TITLE = 'Git Reports'.freeze
  DESCRIPTION = 'Git Reports is a free service that lets you set up a stable URL for anonymous users to submit bugs and other Issues to your GitHub repositories.'.freeze
  KEYWORDS = 'GitHub, git, issue, report, bug'.freeze

  def default_meta
    {
      description: DESCRIPTION,
      keywords: KEYWORDS,
      title: TITLE,
      icon: '/favicon.ico',
      viewport: 'width=device-width, initial-scale=1.0',
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
    case flash_type.to_sym
    when :success
      'alert-success'
    when :error
      'alert-danger'
    when :notice
      'alert-info'
    end
  end
end
