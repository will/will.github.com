def first_post
  all_posts.first
end

def next_post(post)
  all_posts[ all_posts.rindex(post) - 1 ]
end

def prev_post(post)
  all_posts[ all_posts.rindex(post) + 1 ]
end

def all_posts
  @all_pages ||= @pages.find( :limit => :all,
                              :draft => nil,
                              :sort_by => "created_at",
                              :blog_post => true,
                              :reverse => true
                            )
end

def other_posts(post=nil)
  post ||= @page
  npost = next_post(post)
  ppost = prev_post(post)
  html = "<div class='otherposts'><ul>"
  html += "<li>&nbsp;&nbsp;&nbsp;&nbsp;Next Post: #{link_to_post npost}</li>" if npost unless post == first_post
  html += "<li>Previous Post: #{link_to_post ppost }</li>" if ppost
  html += "</ul></div>"
end

def link_to_post(post)
  link_to post.title, post.url
end

def find_post(title)
  @pages.find( :limit => 1, :title => title).first
end

def open_id_delegation
  return unless @page.url == "/"
  %Q{
  <!-- openid delegation -->
  <link rel="openid.server" href="http://www.myopenid.com/server" />
  <link rel="openid.delegate"href="http://wl.myopenid.com/" />
  <link rel="openid2.local_id" href="http://wl.myopenid.com" />
  <link rel="openid2.provider" href="http://www.myopenid.com/server" />
  <meta http-equiv="X-XRDS-Location" content="http://www.myopenid.com/xrds?username=wl.myopenid.com" />
  }
end