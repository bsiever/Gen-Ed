# SPDX-FileCopyrightText: 2023 Mark Liffiton <liffiton@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

from dataclasses import dataclass, field

from flask import current_app, Flask
from gened.contexts import ContextConfig, register_context
from jinja2 import Environment
from typing_extensions import Self
from werkzeug.datastructures import ImmutableMultiDict


def _default_langs() -> list[str]:
    langs: list[str] = current_app.config['DEFAULT_LANGUAGES']  # declaration keeps mypy happy
    return langs

jinja_env = Environment(
    trim_blocks=True,
    lstrip_blocks=True,
    autoescape=True,
)


@dataclass(frozen=True)
class CodeHelpContext(ContextConfig):
    name: str
    tools: str = ''
    details: str = ''
    avoid: str = ''
    template: str = "codehelp_context_form.html"

    @classmethod
    def from_request_form(cls, form: ImmutableMultiDict[str, str]) -> Self:
        return cls(
            name=form['name'],
            tools=form.get('tools', ''),
            details=form.get('details', ''),
            avoid=form.get('avoid', ''),
        )

    @staticmethod
    def _list_fmt(s: str) -> str:
        if s:
            return ', '.join(s.split('\n'))
        else:
            return ''

    def prompt_str(self) -> str:
        """ Convert this context into a string to be used in an LLM prompt. """
        template = jinja_env.from_string("""\
{% if tools %}
Environment and tools: <tools>{{ tools }}</tools>
{% endif %}
{% if details %}
Details: <details>{{ details }}</details>
{% endif %}
{% if avoid %}
Keywords and concepts to avoid (do not mention these in your response at all): <avoid>{{ avoid }}</avoid>
{% endif %}
""")
        return template.render(tools=self._list_fmt(self.tools), details=self.details, avoid=self._list_fmt(self.avoid))

    def desc_html(self) -> str:
        """ Convert this context into a description for users in HTML.

        Does not include the avoid set (not necessary to show students).
        """
        template = jinja_env.from_string("""\
{% if tools %}
<p><b>Environment & tools:</b> {{ tools }}</p>
{% endif %}
{% if details %}
<p><b>Details:</b></p>
{{ details | markdown }}
{% endif %}
""")
        return template.render(tools=self._list_fmt(self.tools), details=self.details, avoid=self._list_fmt(self.avoid))


def init_app(app: Flask) -> None:
    """ Register the custom context class with Gen-Ed,
    and grab a copy of the app's markdown filter for use here.
    """
    register_context(CodeHelpContext)
    jinja_env.filters['markdown'] = app.jinja_env.filters['markdown']
