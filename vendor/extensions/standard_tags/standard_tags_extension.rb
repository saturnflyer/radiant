class StandardTagsExtension < Radiant::Extension
  version "1.0"
  description "Standard Radius tags for Radiant"
  url "http://github.com/saturnflyer/radiant-standard_tags-extension"
  
  def activate
    Page.class_eval { 
      include Radiant::Taggable
      include LocalTime
      include StandardTags
      include StandardTags::PageTags
      include StandardTags::ChildrenTags
      include StandardTags::ContentTags
      include StandardTags::AuthorTags
      include StandardTags::ParentTags
      include StandardTags::FinderTags
    }
  end
end
