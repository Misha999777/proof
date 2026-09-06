export async function proofread(messages, customApiUrl, customApiKey, customModel) {
  const apiUrl = customApiUrl || localStorage.getItem('apiUrl');
  const apiKey = customApiKey || localStorage.getItem('apiKey');
  const model = customModel || localStorage.getItem('model');

  if (!apiUrl || !apiKey || !model) {
    return { success: false, text: 'API not configured' };
  }

  let urlString = apiUrl;
  if (!urlString.endsWith('/chat/completions')) {
    if (!urlString.endsWith('/')) {
      urlString += '/';
    }
    urlString += 'chat/completions';
  }

  try {
    const response = await fetch(urlString, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model,
        messages
      })
    });

    if (!response.ok) {
      return { success: false, text: 'API Error' };
    }

    const data = await response.json();
    let text = data?.choices?.[0]?.message?.content;
    
    if (text) {
      // Remove <thought>...</thought> blocks that might come from some models
      text = text.replace(/<thought>[\s\S]*?<\/thought>/g, '').trim();
      return { success: true, text };
    }

    return { success: false, text: 'Invalid response format' };
  } catch (err) {
    return { success: false, text: 'API Error' };
  }
}
