import { useState, useEffect } from 'react';

import { FluentProvider, webLightTheme, webDarkTheme } from '@fluentui/react-components';

import SettingsView from './components/SettingsView';
import ProofreadingView from './components/ProofreadingView';

import styles from './styles/App.module.css';

function App() {
  const [isConfigured, setIsConfigured] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [theme, setTheme] = useState(
    window.matchMedia('(prefers-color-scheme: dark)').matches ? webDarkTheme : webLightTheme
  );

  useEffect(() => {
    const url = localStorage.getItem('apiUrl');
    const key = localStorage.getItem('apiKey');
    const model = localStorage.getItem('model');
    setIsConfigured(!!(url && key && model));
  }, []);

  useEffect(() => {
    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    const handleChange = (e) => setTheme(e.matches ? webDarkTheme : webLightTheme);
    mq.addEventListener('change', handleChange);
    return () => mq.removeEventListener('change', handleChange);
  }, []);

  const handleSettingsClosed = () => {
    setShowSettings(false);
    const url = localStorage.getItem('apiUrl');
    const key = localStorage.getItem('apiKey');
    const model = localStorage.getItem('model');
    setIsConfigured(!!(url && key && model));
  };

  const shouldShowSettings = showSettings || !isConfigured;

  return (
    <FluentProvider theme={theme} className={styles.root}>
      {shouldShowSettings ? (
        <SettingsView onClose={handleSettingsClosed} isConfigured={isConfigured} />
      ) : (
        <ProofreadingView onShowSettings={() => setShowSettings(true)} />
      )}
    </FluentProvider>
  );
}

export default App;
