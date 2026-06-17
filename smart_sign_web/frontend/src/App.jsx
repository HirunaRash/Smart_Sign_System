import { useEffect, useState } from 'react';
import api from './api';

function App() {
  const [data, setData] = useState(null);

  useEffect(() => {
    api.get('/weatherforecast')
      .then(res => setData(res.data))
      .catch(err => console.error('API connection failed:', err));
  }, []);

  return <div>{data ? JSON.stringify(data) : 'Loading or no connection yet...'}</div>;
}

export default App;