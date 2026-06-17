export function createAuthStore() {
    let token = $state<string | null>(null);
    let user = $state<{ id: number; username: string; email: string } | null>(null);
    let isInitialized = $state(false);

    function init() {
        if (typeof window !== 'undefined') {
            const storedToken = localStorage.getItem('ondina_token');
            if (storedToken) {
                token = storedToken;
                fetchUser(storedToken);
            } else {
                isInitialized = true;
            }
        }
    }

    async function fetchUser(currentToken: string) {
        try {
            const res = await fetch('http://localhost:4000/api/me', {
                headers: { 'Authorization': `Bearer ${currentToken}` }
            });
            if (res.ok) {
                const data = await res.json();
                user = data.user;
            } else {
                logout(); // Token inválido ou expirado
            }
        } catch (e) {
            console.error('Falha ao verificar token', e);
        } finally {
            isInitialized = true;
        }
    }

    function login(newToken: string, userData: any) {
        token = newToken;
        user = userData;
        if (typeof window !== 'undefined') {
            localStorage.setItem('ondina_token', newToken);
        }
    }

    function logout() {
        token = null;
        user = null;
        if (typeof window !== 'undefined') {
            localStorage.removeItem('ondina_token');
        }
    }

    return {
        get token() { return token; },
        get user() { return user; },
        get isAuthenticated() { return !!user; },
        get isInitialized() { return isInitialized; },
        init,
        login,
        logout
    };
}

export const auth = createAuthStore();
