# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'date'

blank_date = "-" # thisis shows where no date is specified
SCHEDULER.every '10m', :first_in => 0 do |job| # this indicates the job will be fired in every 10 minutes interval
    # followings will be used to hold data for specific columns in dashboard
    open_tickets = Array.new
    eval_tickets = Array.new
    in_progress_tickets = Array.new
    nr_of_open = 0
    nr_of_eval = 0
    nr_of_in_progress = 0
    max_number_of_item_per_col = 7

    json = `python jobs/ps_nemea_job.py` # this executes the python script that communicates with JIRA to collect products under planning sueue.
    data = JSON.parse(json, symbolize_names: true) # parse the data in JSON format

    issue_list = data[:issues]
    
    #filter the tickets with status
    for issue in issue_list
        status = issue[:fields][:status][:name]
        if (status == "Open")
            nr_of_open += 1
            if (nr_of_open.to_i <= max_number_of_item_per_col.to_i)
                open_tickets << issue
            end
        elsif (status == "Eval")
            nr_of_eval += 1
            if (nr_of_eval.to_i <= max_number_of_item_per_col.to_i)
                eval_tickets << issue
            end
        elsif (status == "In Progress")
            nr_of_in_progress += 1
            if (nr_of_in_progress.to_i <= max_number_of_item_per_col.to_i)
                in_progress_tickets << issue
            end
        end
    end
    
    open_tickets_dict = Array.new
    eval_tickets_dict = Array.new
    in_progress_tickets_dict = Array.new
        
    for open_issue in open_tickets
        summary = open_issue[:fields][:summary]
        proj_nr = open_issue[:fields][:customfield_12743]
        proj_manager = open_issue[:fields][:customfield_12744]
        if (proj_manager.nil?)
            proj_manager = "None"
        else
            proj_manager = proj_manager[:displayName]
        end
        rag_status = open_issue[:fields][:customfield_12741]
        duedate = open_issue[:fields][:duedate]
        completion = open_issue[:fields][:customfield_12847]
        status = open_issue[:fields][:status][:name]
        open_tickets_dict << {"summary" => summary, "proj_nr" => proj_nr, "proj_manager" => proj_manager, "rag_status" => rag_status, "duedate" => duedate, "completion" => completion, "status" => status}
    end
    

    for eval_issue in eval_tickets
        summary = eval_issue[:fields][:summary]
        proj_nr = eval_issue[:fields][:customfield_12743]
        proj_manager = eval_issue[:fields][:customfield_12744]
        if (proj_manager.nil?)
            proj_manager = "None"
        else
            proj_manager = proj_manager[:displayName]
        end
        rag_status = eval_issue[:fields][:customfield_12741]
        duedate = evalissue[:fields][:duedate]
        completion = eval_issue[:fields][:customfield_12847]
        status = eval_issue[:fields][:status][:name]
        eval_tickets_dict << {"summary" => summary, "proj_nr" => proj_nr, "proj_manager" => proj_manager, "rag_status" => rag_status, "duedate" => duedate, "completion" => completion, "status" => status}
    end


    for in_progress_issue in in_progress_tickets
        summary = in_progress_issue[:fields][:summary]
        proj_nr = in_progress_issue[:fields][:customfield_12743]
        proj_manager = in_progress_issue[:fields][:customfield_12744]
        if (proj_manager.nil?)
            proj_manager = "None"
        else
            proj_manager = proj_manager[:displayName]
        end
        rag_status = in_progress_issue[:fields][:customfield_12741]
        duedate = in_progress_issue[:fields][:duedate]
        completion = in_progress_issue[:fields][:customfield_12847]
        status = in_progress_issue[:fields][:status][:name]
        in_progress_tickets_dict << {"summary" => summary, "proj_nr" => proj_nr, "proj_manager" => proj_manager, "rag_status" => rag_status, "duedate" => duedate, "completion" => completion, "status" => status}
    end
    
    send_event('open_tickets_dashboard',
        {
            header: "Open",
            rows: open_tickets_dict
        })

    send_event('eval_tickets_dashboard',
        {
            header: "Under Evaluation",
            rows: eval_tickets_dict
        })

    send_event('in_progress_tickets_dashboard',
        {
            header: "In Progress",
            rows: in_progress_tickets_dict
        })
end

