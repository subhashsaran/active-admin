Every web developer knows that creating an administration interface for their projects is an incredibly tedious task. Luckily, there are tools that make this task considerably simpler. In this tutorial, I’ll show you how to use Active Admin, a recently launched administration framework for Ruby on Rails applications.

You can use Active Admin to add an administration interface to your current project, or you can even use it to create a complete web application from scratch - quickly and easily.

Today, we’ll be doing the latter, by creating a fairly simple project management system. It might sound like quite a bit of work, but Active Admin will do the bulk of the work for us!

Create the application we’ll be working on, by running the following command in your Terminal:

```
rails new active_admin
```

Next, open your Gemfile and add the following lines:

```
gem 'activeadmin'
```
Next, we need to finish installing Active Admin, by running the following command:
```
rails generate active_admin:install
```
This will generate all needed initializers and migrations for Active Admin to work. It will also create an AdminUser model for authentication, so run rake db:migrate to create all the needed database tables. Apart from that, you need to add one line to your config/environments/development.rb file, so sending emails works:

```
onfig.action_mailer.default_url_options = { :host => 'localhost:3000' }
```
Once that’s done, start  server and hit localhost:3000/admin. You’ll be see a nice login form. Just type “admin@example.com” as the email and “password” as the password, and hit “Login”. You should now see a nice administration interface.

Configuring our User Model

As you can see from the webpage you just generated, there’s not much you can do, yet. We’re going to need a way to edit our users, and we can do that using Active Admin. The framework uses what it calls “Resources”. Resources map models to administration panels. You need to generate them using a command in your terminal, so Active Admin can know their existence, so go ahead and run:

```
rails generate active_admin:resource AdminUser
```
The syntax for that command is simple: just write the database model’s name at the end. This will generate a file inside the app/admin folder, called admin_users.rb. Now, if you refresh your browser you’ll see a new link at the top bar, called “Admin Users”. Clicking that will take you to the Admin User administration panel. Now, it’ll probably look a little too cluttered, since by default, Active Admin shows all of the model’s columns, and considering that the framework uses Devise for authentication, you’ll see a bunch of columns that are not really necessary. This takes us to the first part of our customization: the index page.

Customizing Active Admin resources is fairly easy (and fun if you ask me). Open app/admin/admin_users.rb on your favorite text editor and make it look like this:

```
ActiveAdmin.register AdminUser do
  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end
end
```
Let’s review the code:


 The first line is created by Active Admin, and, like it says, it registers a new resource. This created the menu link at the top bar and all of the default actions, like the table you just saw.

 The index method allows us to customize the index view, which is the table that shows all rows.
   
 Inside of the block you pass to the index method, you specify which columns you do want to appear on the table, ie. writing column :email will have Active Admin show that column on the view.
 
 default_actions is a convenience method that creates one last column with links to the detail, edition and deletion of the row.

One final step for this view is to customize the form. If you click the “New Admin User” link on the top right, you’ll see that the form also contains all of the columns on the model, which is obviously not very useful. Since Active Admin uses Devise, we only need to enter an email address to create a user, and the rest should be taken care of by the authentication gem. To customize the forms that Active Admin displays, there’s a method, called (you guessed it) form:

```
ctiveAdmin.register AdminUser do
  index do
    # ...
  end
 
  form do |f|
    f.inputs "Admin Details" do
      f.input :email
    end
    f.buttons
  end
end
```


 You specify the form’s view by calling the form method and passing it a block with an argument (f in this case).

f.inputs creates a fieldset. Word of advice: you have to add at least one fieldset. Fields outside of one will simply not appear on the view.
   
 To create a field, you simply call f.input and pass a symbol with the name of the model’s column, in this case, “email”.
 
 f.buttons creates the “Submit” and “Cancel” buttons.

 You can further customize the forms using the DSL (Domain Specific Language) provided by Formtastic, so take a look at tutorials about this gem.

One last step for this form to work: since we’re not providing a password, Devise is not going to let us create the record, so we need to add some code to the AdminUser model:

```
after_create { |admin| admin.send_reset_password_instructions }
 
def password_required?
  new_record? ? false : super
end

```
The after_create callback makes sure Devise sends the user a link to create a new password, and the password_required? method will allow us to create a user without providing a password.

Go try it out. Create a user, and then check your email for a link, which should let you create a new password, and log you into the sytem.



Step3-Projects 

We are going to create a simple Project Management system. Not anything too complicated though, just something that will let us manage projects and tasks for the project, and assign tasks to certain users. First thing, is to create a project model:


```
rails generate model Project title:string
```
Active Admin relies on Rails’ models for validation, and we don’t want projects with no title, so let’s add some validations to the generated model:

```
# rails
validates :title, :presence => true
```
Now, we need to generate an Active Admin resource, by running:

```
rails generate active_admin:resource Project
```

For now, that’s all we need for projects. After migrating your database, take a look at the interface that you just created. Creating a project with no title fails, which is what we expected. See how much you accomplished with just a few lines of code?


Step4-- Tasks

Projects aren’t very useful without tasks right? Let’s add that:

```
rails generate model Task project_id:integer admin_user_id:integer title:string is_done:boolean due_date:date
```

This creates a task model that we can associate with projects and users. The idea is that a task is assigned to someone and belongs to a project. We need to set those relations and validations in the model:

```
class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :admin_user
 
  validates :title, :project_id, :admin_user_id, :presence => true
  validates :is_done, :inclusion => { :in => [true, false] }
end

```
Remember to add the relations to the Project and AdminUser models as well:

```
class AdminUser < ActiveRecord::Base
  has_many :tasks
 
  # ...
end
```
```
class Project < ActiveRecord::Base
  has_many :tasks
 
  # ...
end
```
Migrate the database, and register the task model with Active Admin:

```
rails generate active_admin:resource Task
```
Now go and take a look at the tasks panel in your browser. You just created a project management system! Good job.

 Making It Even Better

The system we just created isn’t too sophisticated. Luckily, Active Admin is not just about creating a nice scaffolding system, it gives you far more power than that. Let’s start with the Projects section. We don’t really need the id, created and updated columns there, and we certainly don’t need to be able to search using those columns. Let’s make that happen:

```
index do
  column :title do |project|
    link_to project.title, admin_project_path(project)
  end
 
  default_actions
end
 
# Filter only by title
filter :title
```
A few notes here:


    When you specify columns, you can customize what is printed on every row. Simply pass a block with an argument to it, and return whatever you want in there. In this case, we are printing a link to the project’s detail page, which is easier than clicking the “View” link on the right.
    The filters on the right are also customizable. Just add a call to filter for every column you want to be able to filter with.


 The project’s detail page is a little boring don’t you think? We don’t need the date columns and the id here, and we could show a list of the tasks more directly. Customizing the detail page is accomplished by using the show method in the app/admin/projects.rb file:
 


 ```
 show :title => :title do
  panel "Tasks" do
    table_for project.tasks do |t|
      t.column("Status") { |task| status_tag (task.is_done ? "Done" : "Pending"), (task.is_done ? :ok : :error) }
      t.column("Title") { |task| link_to task.title, admin_task_path(task) }
      t.column("Assigned To") { |task| task.admin_user.email }
      t.column("Due Date") { |task| task.due_date? ? l(task.due_date, :format => :long) : '-' }
    end
  end
end
```

Let’s walk through the code:


    show :title => :title specifies the title the page will have. The second :title specifies the model’s column that will be used.
    By calling panel "Tasks" we create a panel with the given title. Within it, we create a custom table for the project’s tasks, using table_for.
    We then specify each column and the content’s it should have for each row.
        The “Status” column will contain “Done” or “Pending” whether the task is done or not. status_tag is a method that renders the word passed with a very nice style, and you can define the color by passing a second argument with either : ok, :warning and :error for the colors green, orange and red respectively.
        The “Title” column will contain a link to the task so we can edit it.
        The “Assigned To” column just contains the email of the person responsible.
        The “Due Date” will contain the date the task is due, or just a “-” if there’s no date set.



Step6-  Some Tweaks for the Tasks

How about an easy way to filter tasks that are due this week? Or tasks that are late? That’s easy! Just use a scope. In the tasks.rb file, add this:

```
scope :all, :default => true
scope :due_this_week do |tasks|
  tasks.where('due_date > ? and due_date < ?', Time.now, 1.week.from_now)
end
scope :late do |tasks|
  tasks.where('due_date < ?', Time.now)
end
scope :mine do |tasks|
  tasks.where(:admin_user_id => current_admin_user.id)
end
```
Let’s review that code:


    scope :all defines the default scope, showing all rows.
    scope accepts a symbol for the name, and you can pass a block with an argument. Inside the block you can refine a search according to what you need. You can also define the scope inside the model and simply name it the same as in this file.
    As you can see, you can access the current logged in user’s object using current_admin_user.

Check it out! Just above the table, you’ll see some links, which quickly show you how many tasks there are per scope, and lets you quickly filter the list. You should further customize the table and search filters, but I’ll leave that task to you.

We’re now going to tweak the task’s detail view a bit, since it looks rather cluttered:

```
show do
  panel "Task Details" do
    attributes_table_for task do
      row("Status") { status_tag (task.is_done ? "Done" : "Pending"), (task.is_done ? :ok : :error) }
      row("Title") { task.title }
      row("Project") { link_to task.project.title, admin_project_path(task.project) }
      row("Assigned To") { link_to task.admin_user.email, admin_admin_user_path(task.admin_user) }
      row("Due Date") { task.due_date? ? l(task.due_date, :format => :long) : '-' } 
    end
  end
 
  active_admin_comments
end
```
This will show a table for the attributes of the model (hence the method’s name, attributes_table_for). You specify the model, in this case task, and in the block passed, you define the rows you want to show. It’s roughly the same we defined for the project’s detail page, only for the task. You may be asking yourself: What’s that “active_admin_comments” method call for? Well, Active Admin provides a simple commenting system for each model. I enabled it here because commenting on a task could be very useful to discuss functionality, or something similar. If you don’t call that method, comments will be hidden.

There’s another thing I’d like to show when viewing a task’s detail, and that’s the rest of the assignee’s tasks for that project. That’s easily done using sidebars!

```
sidebar "Other Tasks For This User", :only => :show do
  table_for current_admin_user.tasks.where(:project_id => task.project) do |t|
    t.column("Status") { |task| status_tag (task.is_done ? "Done" : "Pending"), (task.is_done ? :ok : :error) }
    t.column("Title") { |task| link_to task.title, admin_task_path(task) }
  end
end
```
This creates a sidebar panel, titled “Other Tasks For This User”, which is shown only on the “show” page. It will show a table for the currentadminuser, and all tasks where the project is the same as the project being shown (you see, task here will refer to the task being shown, since it’s a detail page for one task). The rest is more or less the same as before: some columns with task details.

Step7-The Dashboard

You may have noticed, when you first launched your browser and logged into your app, that there was a “Dashboard” section. This is a fully customizable page where you can show nearly anything: tables, statistics, whatever. We’re just going to add the user’s task list as an example. Open up the dashboards.rb file and revise it, like so:


```
ActiveAdmin::Dashboards.build do
  section "Your tasks for this week" do
    table_for current_admin_user.tasks.where('due_date > ? and due_date < ?', Time.now, 1.week.from_now) do |t|
      t.column("Status") { |task| status_tag (task.is_done ? "Done" : "Pending"), (task.is_done ? :ok : :error) }
      t.column("Title") { |task| link_to task.title, admin_task_path(task) }
      t.column("Assigned To") { |task| task.admin_user.email }
      t.column("Due Date") { |task| task.due_date? ? l(task.due_date, :format => :long) : '-' }
    end
  end
 
  section "Tasks that are late" do
    table_for current_admin_user.tasks.where('due_date < ?', Time.now) do |t|
      t.column("Status") { |task| status_tag (task.is_done ? "Done" : "Pending"), (task.is_done ? :ok : :error) }
      t.column("Title") { |task| link_to task.title, admin_task_path(task) }
      t.column("Assigned To") { |task| task.admin_user.email }
      t.column("Due Date") { |task| task.due_date? ? l(task.due_date, :format => :long) : '-' }
    end
  end
end
```
The code should be fairly familiar to you. It essentially creates two sections (using the section method and a title), with one table each, which displays current and late tasks, respectively.


Conclusion

We’ve created an extensive application in very few steps. You may be surprised to know that there are plenty more features that Active Admin has to offer, but it's not possible to cover them all in just one tutorial, certainly. If you’re interested in learning more about this gem, visit activeadmin.info.

You also might like to check out my project, called active_invoices on GitHub, which is a complete invoicing application made entirely with Active Admin.
















































