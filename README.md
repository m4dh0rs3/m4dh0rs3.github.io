## Build info

Clone recursive submodules:

```Bash
git clone --recurse-submodules https://github.com/m4dh0rs3/m4dh0rs3.github.io.git
git submodule init
git submodule update
git submodule update --init --recursive # needed when you reclone your repo (submodules may not get cloned automatically)
```

Check results

```Bash
hugo server
```

Commit & push, than:

```Bash
bash deploy.sh
``` 

## Custom theme goals

- Font: [Recursive Design](https://www.recursive.design/)
- Markdown style html: `#` and `*`
- Auto light/dark theme, switcher button
- Theme: [Hyperlink Minimal](https://material.io/resources/color/#!/?view.left=0&view.right=1&primary.color=CFD8DC&secondary.color=3e1cff&primary.text.color=546E7A)
- TL;DR posts list
- Hugo Base-Theme: [Accesable Minimalism](https://themes.gohugo.io/accessible-minimalism-hugo-theme/)
- [UBlogger Code Blocks](https://ublogger.netlify.app/theme-documentation-built-in-shortcodes/)