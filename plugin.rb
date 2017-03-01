# name: dl-customizations
# about: Random edits and tweaks for discourseleague.com
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/discourseleague/dl-customizations

enabled_site_setting :dl_customizations_enabled

after_initialize do

  DiscourseEvent.on(:league_level_page_visited) do |user_id, level_id|
    Jobs.enqueue(:league_level_page_visited, {user_id: user_id, level_id: level_id})
  end

  require_dependency "jobs/base"
  module ::Jobs

    class LeagueLevelPageVisited < Jobs::Base
      def execute(args)
        visits = PluginStore.get("dl_customizations", "league_level_page_visits") || []
        visit = visits.select{|visit| visit[:user_id] == args[:user_id] && visit[:level_id] == args[:level_id] }
        time = Time.now

        if visit.empty?
          id = visits.count + 1

          new_visit = {
            id: id,
            user_id: args[:user_id],
            level_id: args[:level_id],
            first_visited_date: time,
            last_visited_date: time,
            visit_count: 1
          }

          visits.push(new_visit)
        else
          new_visit_count = visit[0][:visit_count] + 1
          visit[0][:last_visited_date] = time
          visit[0][:visit_count] = new_visit_count
        end

        PluginStore.set("dl_customizations", "league_level_page_visits", visits)
      end
    end

  end

end