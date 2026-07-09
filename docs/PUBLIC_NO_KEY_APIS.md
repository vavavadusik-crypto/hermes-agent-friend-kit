# Public/no-key API, которые можно использовать без регистрации

Эти источники полезны для research, парсинга, карточек, бордов, справок, ссылок и базовой автоматизации. Они не заменяют LLM provider, но дают бесплатные данные.

## Wikimedia / Wikipedia / Commons

- MediaWiki Action API: https://www.mediawiki.org/wiki/API:Action_API
- Wikipedia endpoint example: `https://en.wikipedia.org/w/api.php`
- Wikimedia Commons endpoint: `https://commons.wikimedia.org/w/api.php`

Пример поиска:

```bash
curl 'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=Hermes%20Agent&format=json'
```

## Wikidata

- Wikidata main: https://www.wikidata.org/wiki/Wikidata:Main_Page
- Query service: https://query.wikidata.org/

SPARQL endpoint:

```text
https://query.wikidata.org/sparql
```

## Crossref

- REST API: https://www.crossref.org/documentation/retrieve-metadata/rest-api/
- Access/auth: https://www.crossref.org/documentation/retrieve-metadata/rest-api/access-and-authentication/

Crossref прямо указывает, что public REST API можно использовать без регистрации. В polite mode лучше добавлять email через `mailto`.

Пример:

```bash
curl 'https://api.crossref.org/works?query=autonomous%20agents&rows=5'
```

## arXiv

- API manual: https://info.arxiv.org/help/api/user-manual.html
- API access: https://info.arxiv.org/help/api/index.html

Пример:

```bash
curl 'https://export.arxiv.org/api/query?search_query=all:agentic%20ai&start=0&max_results=5'
```

## Open Library

- Search endpoint: https://openlibrary.org/dev/docs/api/search

Пример:

```bash
curl 'https://openlibrary.org/search.json?q=artificial%20intelligence&limit=5'
```

## GitHub public search

GitHub public endpoints можно использовать без токена, но лимиты ниже. Для стабильной работы лучше добавить `GITHUB_TOKEN`.

Пример:

```bash
curl 'https://api.github.com/search/repositories?q=hermes+agent&per_page=5'
```

## Правила хорошего поведения

- Указывай User-Agent, если делаешь много запросов.
- Не спамь endpoint запросами.
- Кэшируй ответы.
- Соблюдай Terms of Use каждого источника.
- Для Crossref используй polite mode с email, если проект станет публичным.

