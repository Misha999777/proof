export async function proofread(messages, customApiUrl, customApiKey, customModel) {
  const apiUrl = customApiUrl || localStorage.getItem('apiUrl');
  const apiKey = customApiKey || localStorage.getItem('apiKey');
  const model = customModel || localStorage.getItem('model');

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
    let text = data.choices[0].message.content;
    
    return { success: true, text };
  } catch (err) {
    return { success: false, text: 'API Error' };
  }
}
