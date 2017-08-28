# pygments

Highlight source code snippets in your HTML files using pygments.

## Usage:

In *pubspec.yaml*:

```yaml
dependencies:
  pygments: any

transformers:
  - pygments:
      # Here we define all the HTML elements pygments will run on
      classes:
        # First comes the DOM selector. This will match all *pre* elements that contain a class
        # starting with *language*. For instance, this will match <pre class="language-python">.
        # Note that these are just 100% standard DOM selectors!!
        # Also note that an outer code tag will be stripped. e.g. given
        # <pre class="langauge-python"><code>def main: return 0</code></pre>, the transformer will
        # automatically lift out the *def main: return 0* and only highlight that, ignoring the
        # outer code tag.
        - "pre[class|='language']":
            # Now we need to define the source language. You can do this using a regex as shown
            # below. This will match the language-* class and extract just the language name
            # (e.g. language-dart -> dart).
            re: "language-(.*)"
            # By default, pygments will automatically unescape any HTML escape codes. For example,
            # <pre>a &gt; b</pre> will be converted to *a > b*. Set unescape to false to disable
            # this.
            unescape: false
        # Here's another example. This will run only on elements like <pre class="dart"></pre>.
        - "pre[class=dart]":
            # If your language is constant, you don't need to use a regex. Just use the lang
            # property instead:
            lang: dart
        # Last example! This is for CSS:
        - "pre[class=css]":
            # In the cases where you aren't passing any other options, the default option will
            # be *lang*. So something like:
            # - "pre[class=dart]":
            #     lang: dart
            # can be shortened to:
            # - "pre[class=dart]": dart
            css
```
