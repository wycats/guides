guides
======

This gem provides a clean a simple way to generate and maintain a collection _guides_ or how-to documents for your project.

*guides* is inspired in the Ruby on Rails Guides site (http://guides.rubyonrails.org). Some of the documentation sites that have been built using *guides* include:

* http://guides.sproutcore.com/
* http://guides.dradisframework.org/


Installation
------------

```
$ gem install guides
```

Usage
-----

First create a new working directory.

```
$ cd /tmp/
$ guides new projectguides
$ cd projectguides/
$ guides preview
```

Then open a browser and point it to http://localhost:9292. You will see your new documentation site up and running.

From this point on, it is up to you to customize the site and add additional guides.

Once you are happy with the results, you can generate the final site by running:

```
$ guides build
```

Adding a new guide
------------------

There are two steps required to add a new guide:

* First you need to edit `guides.yml` to add information about the new guide. Pay special attention to the `url` field you choose.
* Then you need to provide the guide's contents by creating a new file under ./source/<url>.textile


Guide authors and contributors
------------------------------

As you will see, the `guides.yml` file also contains a section that lets you define guide authors and contributors. The contents of this section will be rendered to the Credits page (http://localhost:9292/credits.html).

You can include an image field to provide an avatar for each of the contributors. For example:

```
authors:
  Documentation Team:
    - name: John Doe
      nick: johndoe
      image: credits/johndoe.png
      description: Brief bio of J.D.
```

As long as you place your avatar files under `./assets/images/credits/`, *guides* will find it and display it in the Credits page.


Contributing to guides
----------------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so we don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so we can cherry-pick around it.


