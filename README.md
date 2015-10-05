# Rugged::Easy

I use this to make use of Rugged without having to think about Git internals quite so much.

## The ‘git’ Method

To work with the current directory, include the `Rugged::Easy` module:

```ruby
require 'rugged/easy'
include Rugged::Easy
git.init
```

To work with other directories:

```ruby
git = Rugged::Easy::Repository.new('path/to/repo')
git.init
```

Or use block format:

```ruby
Rugged::Easy 'path/to/repo' do |git|
  git.init
end
```

## Author Details

By default, new commits will be authored by 'Rugged::Easy' with email 'rugged@easy'. You can set your own:
 
```ruby
Rugged::Easy.user_name  = 'Neil E. Pearson'
Rugged::Easy.user_email = 'neil@helium.net.au'
```

For a thread-safe option, use block format or a `Repository` instance:

```ruby
git = Rugged::Easy::Repository.new(
  'path/to/repo',
  user_name:  'Neil E. Pearson', 
  user_email: 'neil@helium.net.au'
)
```

## Cheat Sheet

```ruby
# Done:

git.init
git.init :bare
git.add 'filename.ext'
git.add '**/glob.*', '*.more'

# Pending:

git.commit 'Commit message'
git.commit :amend
git.commit amend: 'New message'
git.status                                      # => {staged: {new: ['new_file'], modified: ['changed_file'], deleted: ['deleted_file']},
                                                #   unstaged: {new: ['new_file'], modified: ['changed_file'], deleted: ['deleted_file']}}
git.fetch
git.fetch :origin
git.stash :save
git.stash :pop
git.clean
git.clean :directories
git.push
git.push 'local/branch'
git.push 'local/branch' => :origin
git.push 'local/branch' => {origin: 'remote/branch'}
git.push :force, 'local/branch' => {origin: 'remote/branch'}
git.push nil => {origin: 'remote/branch_to_delete'}
git.reset
git.reset :hard
git.reset hard: 'ref'
git.checkout 'branch_or_tag'
git.checkout 'path/of/file'
git.checkout branch: 'new_branch'
git.branch                                      # => ['current_branch', 'branch_1', ..., 'branch_n']
git.branch :verbose                             # => [{name: 'master', commit: '0519f9f..', message: 'Commit message'}]
git.branch :verbose, :all
git.branch move: 'new_branch_name'
git.branch delete: 'old_branch'
git.branch 'ref' => 'new_branch'
git.rm 'file_to_delete'
git.rm cached: 'file_to_delete_from_index'
git.tag                                         # => ['tag_1', ..., 'tag_n']
git.tag 'tag_name'
```

Except for commands with comments, everything else returns `self`, so chain methods all you want:

```ruby
git.add('file').commit('Commit message').push
```
