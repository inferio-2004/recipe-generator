// frontend/src/Components/RecipeCard.jsx
import React, { useRef, useEffect, useState } from 'react';
import { useSpring, animated as a } from '@react-spring/web';
import '../styles/RecipeCard.css';

export default function RecipeCard({ recipe, onLike = () => {}, onDislike = () => {} }) {
  const rootRef = useRef(null);
  const pointerIdRef = useRef(null);
  const startXRef = useRef(0);
  const lastXRef = useRef(0);
  const movedRef = useRef(false);
  const widthRef = useRef(440);
  const [expanded, setExpanded] = useState(false);
  const [{ x, rot, scale, opacity }, api] = useSpring(() => ({
    x: 0, rot: 0, scale: 1, opacity: 1, config: { tension: 300, friction: 30 }
  }));

  useEffect(() => {
    if (rootRef.current) widthRef.current = rootRef.current.getBoundingClientRect().width || 440;
  }, []);

  const thresholdPx = () => Math.max(120, (widthRef.current || 440) * 0.35);

  function animateSnapBack() {
    api.start({ x: 0, rot: 0, scale: 1, opacity: 1, immediate: false });
  }

  function flyOut(direction, cb) {
    const dist = (widthRef.current || 440) * 1.6 * (direction === 'right' ? 1 : -1);
    api.start({ x: dist, rot: direction === 'right' ? 18 : -18, opacity: 0, onRest: cb });
  }

  // pointer handlers (works for mouse, touch, pen)
  useEffect(() => {
    const node = rootRef.current;
    if (!node) return;

    function onPointerDown(e) {
      // only left button or touch/pen
      if (e.button && e.button !== 0) return;
      // if clicking icon, don't start drag
      if (e.target.closest('.btn-icon')) return;

      pointerIdRef.current = e.pointerId;
      startXRef.current = e.clientX;
      lastXRef.current = 0;
      movedRef.current = false;

      // capture pointer so we continue receiving events
      try { node.setPointerCapture(e.pointerId); } catch (_) {}
      // make spring immediate while dragging
      api.start({ immediate: true });
    }

    function onPointerMove(e) {
      if (pointerIdRef.current !== e.pointerId) return;
      const dx = e.clientX - startXRef.current;
      lastXRef.current = dx;
      if (Math.abs(dx) > 6) movedRef.current = true;
      api.start({ x: dx, rot: dx / 18, scale: 1.02, immediate: true });
    }

    function onPointerUp(e) {
      if (pointerIdRef.current !== e.pointerId) return;
      pointerIdRef.current = null;
      try { node.releasePointerCapture(e.pointerId); } catch (_) {}

      const dx = lastXRef.current;
      const t = thresholdPx();

      if (dx > t) {
        // liked
        flyOut('right', () => onLike(recipe.id));
        return;
      }
      if (dx < -t) {
        // disliked
        flyOut('left', () => onDislike(recipe.id));
        return;
      }

      // if it was a small movement -> treat as click/tap
      if (!movedRef.current) {
        // toggle instructions
        setExpanded(prev => !prev);
      } else {
        // snap back to center
        animateSnapBack();
      }
    }

    node.addEventListener('pointerdown', onPointerDown);
    window.addEventListener('pointermove', onPointerMove);
    window.addEventListener('pointerup', onPointerUp);
    window.addEventListener('pointercancel', onPointerUp);

    return () => {
      node.removeEventListener('pointerdown', onPointerDown);
      window.removeEventListener('pointermove', onPointerMove);
      window.removeEventListener('pointerup', onPointerUp);
      window.removeEventListener('pointercancel', onPointerUp);
    };
  }, [api, onLike, onDislike, recipe]);

  // split instructions by ';' and trim
  const steps = (recipe.instructions || '').split(';').map(s => s.trim()).filter(Boolean);

  // icon click handlers (animate and call callbacks)
  function handleLikeClick(e) {
    e.stopPropagation();
    flyOut('right', () => onLike(recipe.id));
  }
  function handleDislikeClick(e) {
    e.stopPropagation();
    flyOut('left', () => onDislike(recipe.id));
  }

  return (
    <a.div
      ref={rootRef}
      className={`recipe-card ${expanded ? 'expanded' : ''}`}
      role="article"
      aria-expanded={expanded}
      style={{
        touchAction: 'pan-y',
        transform: x.to(xv => `translate3d(${xv}px,0,0)`),
        rotate: rot.to(r => `${r}deg`),
        scale,
        opacity
      }}
    >
      <div className="card-image-wrap">
        <img
          src={recipe.image_url || 'https://via.placeholder.com/600x360?text=No+Image'}
          alt={recipe.title}
          className="card-image"
          style={{ width: '100%', height: '320px', objectFit: 'cover', display: 'block', borderRadius: 8 }}
          loading="lazy"
        />
      </div>

      <div className="card-bottom" onClick={(e) => { if (!movedRef.current) setExpanded(prev => !prev); }}>
        <div className="card-summary-wrap">
          <div className="card-title">{recipe.title}</div>
          <div className="card-summary">{recipe.summary || 'A tasty recipe.'}</div>
        </div>

        <div className="instructions-panel">
          {expanded && steps.length > 0 && (
            <ol className="instructions">
              {steps.map((s, i) => <li key={i}>{s}</li>)}
            </ol>
          )}
        </div>

        <div className="card-actions">
          <button className="btn-icon dislike" title="Dislike" onClick={handleDislikeClick}>❌</button>
          <button className="btn-icon like" title="Like" onClick={handleLikeClick}>❤️</button>
        </div>
      </div>
    </a.div>
  );
}