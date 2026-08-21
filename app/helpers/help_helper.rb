# frozen_string_literal: true

# Renders the deliberately small, safe Markdown subset used by help guides.
module HelpHelper
  def render_help_markdown(markdown)
    safe_join(markdown.to_s.split(/\n{2,}/).filter_map { |block| render_help_block(block) })
  end

  private

  def render_help_block(block)
    lines = block.lines.map(&:strip).reject(&:empty?)
    return if lines.empty?

    return render_help_list(lines) if list_block?(lines)
    return render_help_heading(lines.first) if heading_block?(lines)

    content_tag(:p, safe_join(lines.map { |line| ERB::Util.html_escape(line) }, tag.br))
  end

  def list_block?(lines)
    lines.all? { |line| line.start_with?('- ') }
  end

  def heading_block?(lines)
    lines.one? && lines.first.match?(/\A##? /)
  end

  def render_help_list(lines)
    content_tag(:ul) do
      safe_join(lines.map { |line| content_tag(:li, ERB::Util.html_escape(line.delete_prefix('- '))) })
    end
  end

  def render_help_heading(line)
    level = line.start_with?('## ') ? 2 : 1
    content_tag("h#{level}", ERB::Util.html_escape(line.sub(/\A##? /, '')))
  end
end
