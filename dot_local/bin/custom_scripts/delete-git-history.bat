:: Put this in root folder

Echo "Checkout latest branch"
git checkout --orphan latest_branch
Echo "Adding everything"
git add -A
Echo "Commiting items"
git commit -am "cleanup"
Echo "Deleting main"
git branch -D main
Echo "Creating main"
git branch -m main
Echo "Force pushing back"
git push -f origin main