import { Route, Routes } from 'react-router-dom';
import { Layout } from './Layout';
import { Home } from './Home';
import { PostPage } from './PostPage';
import { About } from './About';
import { NotFound } from './NotFound';

export function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Home />} />
        <Route path="posts/:slug" element={<PostPage />} />
        <Route path="about" element={<About />} />
        <Route path="*" element={<NotFound />} />
      </Route>
    </Routes>
  );
}
